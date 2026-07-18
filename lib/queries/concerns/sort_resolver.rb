# Builds `sortable_columns` ORDER BY lambdas from a small declarative spec
# (association chain + column) via ActiveRecord reflection, instead of
# hand-written SQL per column. Filters use the `direct`/`assoc`/`custom` DSL
# below when declaring `sortable_columns`; `custom` remains the escape hatch
# for cases that aren't a plain association walk (polymorphic type-dispatch
# display labels, aggregates with non-standard semantics).
#
# Security: only `belongs_to`/`has_one`/`has_many` associations *declared on
# the model* are ever reachable -- there is no way to reach an arbitrary
# table from user input, since `sort=` values are matched against the
# `sortable_columns` hash keys (plain strings), never used to build a path.
# The guardrails below (BLACKLISTED_CLASSES, RESTRICTED_COLUMN,
# FOREIGN_KEY_COLUMN, MAX_DEPTH) protect the *authors* of `sortable_columns`
# entries from accidentally exposing a credential column or an unbounded
# join chain; violations raise immediately (at the `sort_by_*`/spec-run call
# site), not silently, since these are developer-time mistakes, not
# user-facing input errors.
module Queries::Concerns::SortResolver
  extend ActiveSupport::Concern

  MAX_DEPTH = 3

  BLACKLISTED_CLASSES = %w[User].freeze
  RESTRICTED_COLUMN = /(password|token|secret|digest|_ip\z|crypt)/i
  FOREIGN_KEY_COLUMN = /\A.+_id\z/

  class_methods do
    # A column on this filter's own table.
    # @param column [Symbol, String]
    def direct(column)
      validate_column!(referenced_klass, column)
      table = referenced_klass.table_name
      col = column.to_s
      ->(q, dir) { q.order(Arel.sql(%(#{table}."#{col}" #{sort_direction(dir)} NULLS LAST))) }
    end

    # An association chain ending in a column, e.g.
    #   assoc(:repository, :name)
    #   assoc(:taxon_determinations, :otu, :name, collapse: :position)
    #   assoc(:loan_recipients, :cached, collapse: :aggregate)
    #
    # @param collapse [Symbol, nil]
    #   Required whenever the chain passes through a `has_many`/`has_many
    #   :through` association -- there is no safe default, since a single
    #   association shape (e.g. acts_as_list + a `position` column) can
    #   legitimately want either semantic depending on the column.
    #   :position  -- use the row with the lowest `position` column.
    #   :aggregate -- collapse to MIN(column) across all matching rows.
    def assoc(*chain, collapse: nil)
      *path, column = chain
      raise ArgumentError, 'assoc requires at least one association and a column' if path.empty?
      raise ArgumentError, "sort path too deep: #{(path + [column]).join('.')}" if path.length > MAX_DEPTH

      build_sort_lambda(referenced_klass, path, column.to_s, collapse)
    end

    # Escape hatch: a fully hand-written `->(q, dir) { ... }` lambda.
    def custom(lam) = lam

    # Every non-blacklisted column on this filter's own table, as a
    # {column_name => lambda} hash. Which columns a filter's UI *displays*
    # is a frontend decision (it already gates sort buttons against whatever
    # this backend reports as sortable) -- there's no separate security
    # reason to hand-curate a smaller list here too.
    def sortable_direct_columns
      safe_columns(referenced_klass).index_with { |c| direct(c) }
    end

    # Every non-blacklisted column on a belongs_to/has_one/has_many
    # association's target class, as a {column_name => lambda} hash.
    # @param collapse [Symbol, nil] forwarded to `assoc` for has_many hops.
    def sortable_assoc_columns(assoc_name, collapse: nil)
      refl = referenced_klass.reflect_on_association(assoc_name)
      raise ArgumentError, "no association :#{assoc_name} on #{referenced_klass}" unless refl

      safe_columns(refl.klass).index_with { |c| assoc(assoc_name, c, collapse:) }
    end

    private

    def safe_columns(klass)
      klass.column_names.select { |c| column_safe?(klass, c) }
    end

    def column_safe?(klass, column)
      col = column.to_s
      return false if col =~ FOREIGN_KEY_COLUMN
      return false if col =~ RESTRICTED_COLUMN
      return false if klass.respond_to?(:encrypted_attributes) && klass.encrypted_attributes&.key?(col)
      true
    end

    def build_sort_lambda(root_klass, path, column, collapse)
      klass = root_klass
      joins = []
      current_alias = root_klass.table_name

      path.each_with_index do |name, i|
        refl = klass.reflect_on_association(name)
        raise ArgumentError, "no association :#{name} on #{klass}" unless refl

        if refl.macro == :has_many
          remaining = path[(i + 1)..]
          lat = has_many_lateral(current_alias, refl, remaining, column, collapse)
          return ->(q, dir) do
            joins.each { |j| q = q.joins(j) }
            q.joins(lat[:sql]).order(Arel.sql(%(#{lat[:alias]}.val #{sort_direction(dir)} NULLS LAST)))
          end
        end

        raise ArgumentError, "unsupported association macro #{refl.macro} for :#{name}" unless %i[belongs_to has_one].include?(refl.macro)
        validate_target_class!(refl.klass)

        alias_name = "sort_#{name}_#{i}"
        joins << single_hop_join(klass, refl, current_alias, alias_name)
        klass = refl.klass
        current_alias = alias_name
      end

      validate_column!(klass, column)
      ->(q, dir) do
        joins.each { |j| q = q.joins(j) }
        q.order(Arel.sql(%(#{current_alias}."#{column}" #{sort_direction(dir)} NULLS LAST)))
      end
    end

    # A single belongs_to/has_one hop. `has_one` (always effectively
    # correlated 1:1 by app invariant) is still built as a LATERAL rather
    # than a plain join, to avoid row multiplication if that invariant is
    # ever violated -- same rationale as the pre-existing
    # sort_by_polymorphic_has_one_column helper.
    def single_hop_join(owner_klass, refl, owner_alias, alias_name)
      if refl.macro == :belongs_to
        raise ArgumentError, 'polymorphic belongs_to is not generically sortable; use custom()' if refl.polymorphic?

        target = refl.klass
        sql = %(LEFT JOIN #{target.table_name} AS #{alias_name} ON #{alias_name}.id = #{owner_alias}.#{refl.foreign_key})
        sql += " AND #{alias_name}.#{target.inheritance_column} = #{quote(target.sti_name)}" if target.finder_needs_type_condition?
        sql
      else
        target = refl.klass
        inner = "#{alias_name}_t"
        where = ["#{inner}.#{refl.foreign_key} = #{owner_alias}.id"]
        where << "#{inner}.#{refl.type} = #{quote(owner_klass.polymorphic_name)}" if refl.type.present?
        where << "#{inner}.#{target.inheritance_column} = #{quote(target.sti_name)}" if target.finder_needs_type_condition?
        <<~SQL.squish
          LEFT JOIN LATERAL (
            SELECT * FROM #{target.table_name} #{inner}
            WHERE #{where.join(' AND ')}
            LIMIT 1
          ) AS #{alias_name} ON true
        SQL
      end
    end

    # Builds the LATERAL for a has_many (direct or :through) hop, optionally
    # continuing through further belongs_to/has_one hops (`remaining`)
    # *inside* the LATERAL before collapsing to a single value.
    def has_many_lateral(owner_alias, refl, remaining, column, collapse)
      raise ArgumentError, "sort path too deep: #{remaining.join('.')}" if remaining.length > MAX_DEPTH

      from_sql, where, current_alias, current_klass = has_many_source(owner_alias, refl)

      extra_joins = []
      remaining.each_with_index do |name, i|
        r = current_klass.reflect_on_association(name)
        raise ArgumentError, "no association :#{name} on #{current_klass}" unless r
        raise ArgumentError, 'only belongs_to/has_one supported after a has_many hop' unless %i[belongs_to has_one].include?(r.macro)
        validate_target_class!(r.klass)

        nxt_alias = "sort_#{name}_r#{i}"
        extra_joins << plain_hop_join(current_klass, r, current_alias, nxt_alias)
        current_klass = r.klass
        current_alias = nxt_alias
      end

      validate_column!(current_klass, column)

      if collapse.nil?
        raise ArgumentError,
          "collapse: is required for has_many hop :#{refl.name} -- pass collapse: :position or collapse: :aggregate"
      end

      select_expr, tail_sql =
        case collapse
        when :aggregate
          raise ArgumentError, 'collapse: :aggregate cannot be combined with further hops' if remaining.any?
          [%(MIN(#{current_alias}."#{column}")), '']
        when :position
          [%(#{current_alias}."#{column}"), "ORDER BY #{has_many_source_alias(refl)}.position LIMIT 1"]
        else
          raise ArgumentError, "unknown collapse strategy #{collapse.inspect}"
        end

      lat_alias = "sort_#{refl.name}"
      sql = <<~SQL.squish
        LEFT JOIN LATERAL (
          SELECT #{select_expr} AS val
          #{from_sql}
          #{extra_joins.join(' ')}
          WHERE #{where.join(' AND ')}
          #{tail_sql}
        ) AS #{lat_alias} ON true
      SQL

      { sql:, alias: lat_alias }
    end

    # FROM + WHERE (correlation to the outer row) for the has_many hop
    # itself, before any `remaining` hops. Handles plain polymorphic
    # has_many and has_many :through (walking through_reflection /
    # source_reflection) uniformly.
    def has_many_source(owner_alias, refl)
      owner_klass = refl.active_record

      if refl.through_reflection
        thr = refl.through_reflection
        src = refl.source_reflection
        thr_klass = thr.klass
        final_klass = src.klass
        thr_alias = has_many_source_alias(refl)
        final_alias = "#{thr_alias}_src"

        where = ["#{thr_alias}.#{thr.foreign_key} = #{owner_alias}.id"]
        where << "#{thr_alias}.#{thr.type} = #{quote(owner_klass.polymorphic_name)}" if thr.type.present?
        where << "#{thr_alias}.#{thr_klass.inheritance_column} = #{quote(thr_klass.sti_name)}" if thr_klass.finder_needs_type_condition?

        from_sql = "FROM #{thr_klass.table_name} #{thr_alias} " \
          "JOIN #{final_klass.table_name} #{final_alias} ON #{final_alias}.id = #{thr_alias}.#{src.foreign_key}"

        [from_sql, where, final_alias, final_klass]
      else
        target = refl.klass
        t_alias = has_many_source_alias(refl)

        where = ["#{t_alias}.#{refl.foreign_key} = #{owner_alias}.id"]
        where << "#{t_alias}.#{refl.type} = #{quote(owner_klass.polymorphic_name)}" if refl.type.present?
        where << "#{t_alias}.#{target.inheritance_column} = #{quote(target.sti_name)}" if target.finder_needs_type_condition?

        ["FROM #{target.table_name} #{t_alias}", where, t_alias, target]
      end
    end

    def has_many_source_alias(refl) = "sort_#{refl.name}_hm"

    # A further belongs_to/has_one hop *inside* a LATERAL. Plain LEFT JOIN
    # is fine here (no row-multiplication risk beyond what the outer
    # LATERAL already isolates per outer row).
    def plain_hop_join(owner_klass, refl, owner_alias, alias_name)
      target = refl.klass
      if refl.macro == :belongs_to
        raise ArgumentError, 'polymorphic belongs_to is not generically sortable; use custom()' if refl.polymorphic?
        sql = "LEFT JOIN #{target.table_name} #{alias_name} ON #{alias_name}.id = #{owner_alias}.#{refl.foreign_key}"
      else
        sql = "LEFT JOIN #{target.table_name} #{alias_name} ON #{alias_name}.#{refl.foreign_key} = #{owner_alias}.id"
        sql += " AND #{alias_name}.#{refl.type} = #{quote(owner_klass.polymorphic_name)}" if refl.type.present?
      end
      sql += " AND #{alias_name}.#{target.inheritance_column} = #{quote(target.sti_name)}" if target.finder_needs_type_condition?
      sql
    end

    def validate_column!(klass, column)
      col = column.to_s
      raise ArgumentError, "#{col} looks like a raw foreign key, sort through the association instead" if col =~ FOREIGN_KEY_COLUMN
      raise ArgumentError, "#{col} is a restricted column" if col =~ RESTRICTED_COLUMN
      if klass.respond_to?(:encrypted_attributes) && klass.encrypted_attributes&.key?(col)
        raise ArgumentError, "#{col} is encrypted and cannot be sorted on"
      end
      raise ArgumentError, "no column #{klass}##{col}" unless klass.column_names.include?(col)
    end

    def validate_target_class!(klass)
      raise ArgumentError, "#{klass} is not reachable for sorting" if BLACKLISTED_CLASSES.include?(klass.name)
    end

    def sort_direction(dir) = dir == :desc ? 'DESC' : 'ASC'

    def quote(value) = ActiveRecord::Base.connection.quote(value)
  end
end
