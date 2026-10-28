# Builds sort key ORDER BY lambdas from an association path and a
# column via ActiveRecord reflection, instead of hand-written SQL per column.
# Queries::Sort::Base subclasses call the `direct`/`association`/`custom` helpers
# below, each of which returns a lambda, when building `columns`; `custom` remains the
# escape hatch for cases that aren't a plain association walk (polymorphic
# type-dispatch display labels, aggregates with non-standard semantics).
#
# Security: only `belongs_to`/`has_one`/`has_many` associations *declared on
# the model* are ever reachable -- there is no way to reach an arbitrary
# table from user input, since `sort=` values are matched against the
# `columns` hash keys (plain strings), never used to build a path.
# The guardrails below (BLACKLISTED_CLASSES, RESTRICTED_COLUMN,
# FOREIGN_KEY_COLUMN, MAX_DEPTH) protect the *authors* of `columns`
# entries from accidentally exposing a credential column or an unbounded
# join chain; violations raise immediately (from the `direct`/`association`
# call, when `columns` is built), not silently, since these are
# developer-time mistakes, not user-facing input errors.
module Queries::Sort::Resolver
  extend ActiveSupport::Concern

  MAX_DEPTH = 3

  # Classes no sort chain may reach. Sorting by a column leaks information
  # about it even when its values are never rendered: someone who can create
  # rows with chosen values can locate a hidden value by where those rows sort
  # relative to it. Most tables are safe to allow by default because results
  # are project-scoped and the data is already visible to project members.
  # User breaks both assumptions: users are shared across projects, and most
  # of their columns (email, sign-in times, is_administrator, preferences,
  # footprints) are never shown to project members. RESTRICTED_COLUMN only
  # catches credential-shaped names, so User is blocked as a whole and
  # columns are opened one at a time below.
  BLACKLISTED_CLASSES = %w[User].freeze

  # The only columns of a BLACKLISTED_CLASSES class that may be sorted on,
  # and only as the final column of a chain (never as a hop to go further).
  # User#name is already shown to project members (creator/updater columns,
  # project member lists), so sorting by it reveals nothing new.
  BLACKLISTED_CLASS_SORTABLE_COLUMNS = { 'User' => %w[name].freeze }.freeze
  RESTRICTED_COLUMN = /(password|token|secret|digest|_ip\z|crypt)/i
  FOREIGN_KEY_COLUMN = /\A.+_id\z/

  # Postgres has no ordering operator for these column types.
  UNORDERABLE_SQL_TYPES = %w[xml json].freeze

  # Separates the values of a `collapse: :joined` sort. Filter tables show
  # multi-valued cells (e.g. identifiers) joined with this, the same
  # separator as DwC exports, so the sort is on the string users see.
  JOINED_SEPARATOR = ' | '.freeze

  class_methods do
    # A column on the model's own table.
    # @param column [Symbol, String]
    def direct(column)
      validate_column!(referenced_klass, column)
      table = referenced_klass.table_name
      col = column.to_s

      ->(q, dir) { order_by_sql(q, %(#{table}."#{col}"), dir) }
    end

    # An association chain ending in a column, e.g.
    #   association(:repository, :name)
    #   association(:taxon_determinations, :otu, :name, collapse: :position)
    #   association(:loan_recipients, :cached, collapse: :aggregate)
    #
    # @param collapse [Symbol, nil]
    #   Required whenever the chain passes through a `has_many`/`has_many
    #   :through` association -- there is no safe default, since a single
    #   association shape (e.g. acts_as_list + a `position` column) can
    #   legitimately want either semantic depending on the column.
    #   :position  -- use the row with the lowest `position` column.
    #   :aggregate -- collapse to MIN(column) across all matching rows.
    #   :joined    -- all values in `position` order, joined with
    #                 JOINED_SEPARATOR, as filter tables display them.
    # @param on [Class, nil]
    #   An STI subclass of the model to reflect the first hop on,
    #   for associations declared only on that subclass, e.g.
    #     association(:serial, :name, on: ::Source::Bibtex)
    #   Rows of other subclasses simply have a NULL foreign key and sort last.
    def association(*chain, collapse: nil, on: nil)
      *path, column = chain
      if path.empty?
        raise ArgumentError, 'association requires at least one association and a column'
      end
      if path.length > MAX_DEPTH
        raise ArgumentError, "sort path too deep: #{(path + [column]).join('.')}"
      end

      root_klass = referenced_klass
      if on
        if !(on < referenced_klass)
          raise ArgumentError, "#{on} is not a subclass of #{referenced_klass}"
        end
        root_klass = on
      end

      build_sort_lambda(root_klass, path, column.to_s, collapse)
    end

    # Escape hatch: a fully hand-written `->(q, dir) { ... }` lambda.
    def custom(lam) = lam

    # Every non-blacklisted column on the model's own table, as a
    # {column_name => lambda} hash. Which columns a filter's UI *displays*
    # is a frontend decision (it already gates sort buttons against whatever
    # this backend reports as sortable) -- there's no separate security
    # reason to hand-curate a smaller list here too.
    def sortable_direct_columns
      safe_columns(referenced_klass).index_with { |c| direct(c) }
    end

    # Every non-blacklisted column on a belongs_to/has_one/has_many
    # association's target class, as a {column_name => lambda} hash.
    # @param collapse [Symbol, nil] forwarded to `association` for has_many hops.
    def sortable_association_columns(association_name, collapse: nil)
      refl = referenced_klass.reflect_on_association(association_name)
      if !refl
        raise ArgumentError, "no association :#{association_name} on #{referenced_klass}"
      end

      safe_columns(refl.klass).index_with { |c| association(association_name, c, collapse:) }
    end

    private

    def safe_columns(klass)
      klass.column_names.select { |c| column_safe?(klass, c) }
    end

    def column_safe?(klass, column)
      col = column.to_s
      return false if col =~ FOREIGN_KEY_COLUMN
      return false if col =~ RESTRICTED_COLUMN
      return false if encrypted?(klass, col)
      return false if UNORDERABLE_SQL_TYPES.include?(klass.columns_hash[col]&.sql_type)
      true
    end

    # Rails keeps encrypted attribute names as a Set of symbols.
    def encrypted?(klass, column)
      klass.respond_to?(:encrypted_attributes) && klass.encrypted_attributes.to_a.map(&:to_s).include?(column.to_s)
    end

    def build_sort_lambda(root_klass, path, column, collapse)
      klass = root_klass
      joins = []
      current_alias = root_klass.table_name

      path.each_with_index do |name, i|
        refl = klass.reflect_on_association(name)
        raise ArgumentError, "no association :#{name} on #{klass}" unless refl

        if refl.macro == :has_one && refl.through_reflection
          raise ArgumentError, "has_one :through (:#{name}) is not generically sortable; use custom()"
        end
        validate_unscoped!(refl)

        if refl.macro == :has_many
          # The rest of the path (`remaining`) is walked inside the LATERAL,
          # so the has_many collapses to one value per row; nothing more is
          # joined out here.
          remaining = path[(i + 1)..]
          lat = has_many_lateral(current_alias, refl, remaining, column, collapse, prefix: path[0...i])
          return ->(q, dir) do
            joins.each { |j| q = q.joins(j) }
            order_by_sql(q.joins(lat[:sql]), "#{lat[:alias]}.val", dir)
          end
        end

        if !%i[belongs_to has_one].include?(refl.macro)
          raise ArgumentError, "unsupported association macro #{refl.macro} for :#{name}"
        end
        validate_target_class!(
          refl.klass, terminal_column: (column if i == path.length - 1)
        )

        alias_name = sort_alias(path[0..i])
        joins << single_hop_join(klass, refl, current_alias, alias_name)
        klass = refl.klass
        current_alias = alias_name
      end

      validate_column!(klass, column)

      ->(q, dir) do
        joins.each { |j| q = q.joins(j) }
        order_by_sql(q, %(#{current_alias}."#{column}"), dir)
      end
    end

    # A single belongs_to/has_one hop, as a plain LEFT JOIN so the planner
    # can choose between per-row index lookups (small results) and a hash
    # join (large results); a LATERAL would force the per-row loop.
    #
    # A has_one is trusted to mean at most one row. If that's ever violated
    # the owner row appears twice in the sorted results -- visible, and the
    # duplicate is already a data error that breaks other things, so it's not
    # hidden here. A unique index on the target's foreign key (+ type), as on
    # dwc_occurrences, enforces it, and also lets Postgres drop the join from
    # the pagination COUNT.
    def single_hop_join(owner_klass, refl, owner_alias, alias_name)
      target = refl.klass

      if refl.macro == :belongs_to
        if refl.polymorphic?
          raise ArgumentError, 'polymorphic belongs_to is not generically sortable; use custom()'
        end
        sql = %(LEFT JOIN #{target.table_name} AS #{alias_name} ON #{alias_name}.#{refl.association_primary_key} = #{owner_alias}.#{refl.foreign_key})
      else
        sql = %(LEFT JOIN #{target.table_name} AS #{alias_name} ON #{alias_name}.#{refl.foreign_key} = #{owner_alias}.#{refl.active_record_primary_key})
        if refl.type.present?
          sql += " AND #{alias_name}.#{refl.type} = #{quote(owner_klass.polymorphic_name)}"
        end
      end

      sql += " AND #{type_condition_sql(target, alias_name)}" if target.finder_needs_type_condition?

      sql
    end

    # Builds the LATERAL for a has_many (direct or :through) hop, optionally
    # continuing through further belongs_to/has_one hops (`remaining`)
    # *inside* the LATERAL before collapsing to a single value.
    # @param prefix [Array<Symbol>] the hops before this one, for the alias
    def has_many_lateral(owner_alias, refl, remaining, column, collapse, prefix: [])
      from_sql, where, current_alias, current_klass = has_many_source(
        owner_alias, refl, terminal_column: (column if remaining.empty?)
      )

      extra_joins = []
      remaining.each_with_index do |name, i|
        r = current_klass.reflect_on_association(name)
        if !r
          raise ArgumentError, "no association :#{name} on #{current_klass}"
        end
        if r.macro == :has_one && r.through_reflection
          raise ArgumentError, "has_one :through (:#{name}) is not generically sortable; use custom()"
        end
        validate_unscoped!(r)
        if !%i[belongs_to has_one].include?(r.macro)
          raise ArgumentError, 'only belongs_to/has_one supported after a has_many hop'
        end
        validate_target_class!(
          r.klass, terminal_column: (column if i == remaining.length - 1)
        )

        nxt_alias = "sort_#{name}_r#{i}"
        extra_joins << plain_hop_join(current_klass, r, current_alias, nxt_alias)
        current_klass = r.klass
        current_alias = nxt_alias
      end

      validate_column!(current_klass, column)

      if collapse.nil?
        raise ArgumentError,
          "collapse: is required for has_many hop :#{refl.name} -- pass collapse: :position, :aggregate or :joined"
      end

      select_expr =
        case collapse
        when :aggregate
          if remaining.any?
            raise ArgumentError, 'collapse: :aggregate cannot be combined with further hops'
          end
          %(MIN(#{current_alias}."#{column}"))
        when :position
          # The first value by position, as an aggregate rather than
          # `ORDER BY position LIMIT 1`: an aggregate with no GROUP BY always
          # returns exactly one row, so Postgres can drop this join from the
          # pagination COUNT; it never drops a LIMIT 1 subquery. `id` breaks
          # ties between rows that share a position.
          source_alias = has_many_source_alias(refl)
          %{(array_agg(#{current_alias}."#{column}" ORDER BY #{source_alias}.position, #{source_alias}.id))[1]}
        when :joined
          # Also a single aggregate, so also dropped from the COUNT. NULL
          # positions come last (ASC default); the display must order its
          # values the same way for the sort to match what it shows.
          source_alias = has_many_source_alias(refl)
          %{string_agg(#{current_alias}."#{column}"::text, #{quote(JOINED_SEPARATOR)} ORDER BY #{source_alias}.position, #{source_alias}.id)}
        else
          raise ArgumentError, "unknown collapse strategy #{collapse.inspect}"
        end

      # The whole path and the column, so two keys through the same has_many
      # (e.g. two taxon_determinations columns), or through has_manys of the
      # same name on different parents, get separate LATERALs.
      lat_alias = sort_alias([*prefix, refl.name, *remaining, column])
      sql = <<~SQL.squish
        LEFT JOIN LATERAL (
          SELECT #{select_expr} AS val
          #{from_sql}
          #{extra_joins.join(' ')}
          WHERE #{where.join(' AND ')}
        ) AS #{lat_alias} ON true
      SQL

      { sql:, alias: lat_alias }
    end

    # FROM + WHERE (correlation to the outer row) for the has_many hop
    # itself, before any `remaining` hops. Handles plain polymorphic
    # has_many and has_many :through (walking through_reflection /
    # source_reflection) uniformly.
    # @param terminal_column [String, nil] see validate_target_class!; the
    #   through table is never terminal.
    def has_many_source(owner_alias, refl, terminal_column: nil)
      owner_klass = refl.active_record

      if refl.through_reflection
        thr = refl.through_reflection
        src = refl.source_reflection
        validate_through_shape!(refl)
        thr_klass = thr.klass
        final_klass = src.klass
        validate_target_class!(thr_klass)
        validate_target_class!(final_klass, terminal_column:)
        thr_alias = has_many_source_alias(refl)
        final_alias = "#{thr_alias}_src"

        where = ["#{thr_alias}.#{thr.foreign_key} = #{owner_alias}.#{thr.active_record_primary_key}"]
        if thr.type.present?
          where << "#{thr_alias}.#{thr.type} = #{quote(owner_klass.polymorphic_name)}"
        end
        where << type_condition_sql(thr_klass, thr_alias) if thr_klass.finder_needs_type_condition?
        where << type_condition_sql(final_klass, final_alias) if final_klass.finder_needs_type_condition?

        from_sql = "FROM #{thr_klass.table_name} #{thr_alias} " \
          "JOIN #{final_klass.table_name} #{final_alias} ON #{final_alias}.#{src.association_primary_key} = #{thr_alias}.#{src.foreign_key}"

        [from_sql, where, final_alias, final_klass]
      else
        target = refl.klass
        validate_target_class!(target, terminal_column:)
        t_alias = has_many_source_alias(refl)

        where = ["#{t_alias}.#{refl.foreign_key} = #{owner_alias}.#{refl.active_record_primary_key}"]
        if refl.type.present?
          where << "#{t_alias}.#{refl.type} = #{quote(owner_klass.polymorphic_name)}"
        end
        where << type_condition_sql(target, t_alias) if target.finder_needs_type_condition?

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
        if refl.polymorphic?
          raise ArgumentError, 'polymorphic belongs_to is not generically sortable; use custom()'
        end
        sql = "LEFT JOIN #{target.table_name} #{alias_name} ON #{alias_name}.#{refl.association_primary_key} = #{owner_alias}.#{refl.foreign_key}"
      else
        sql = "LEFT JOIN #{target.table_name} #{alias_name} ON #{alias_name}.#{refl.foreign_key} = #{owner_alias}.#{refl.active_record_primary_key}"
        if refl.type.present?
          sql += " AND #{alias_name}.#{refl.type} = #{quote(owner_klass.polymorphic_name)}"
        end
      end
      sql += " AND #{type_condition_sql(target, alias_name)}" if target.finder_needs_type_condition?

      sql
    end

    def validate_column!(klass, column)
      col = column.to_s
      if col =~ FOREIGN_KEY_COLUMN
        raise ArgumentError, "#{col} looks like a raw foreign key, sort through the association instead"
      end
      if col =~ RESTRICTED_COLUMN
        raise ArgumentError, "#{col} is a restricted column"
      end
      if encrypted?(klass, col)
        raise ArgumentError, "#{col} is encrypted and cannot be sorted on"
      end
      if !klass.column_names.include?(col)
        raise ArgumentError, "no column #{klass}##{col}"
      end
      if UNORDERABLE_SQL_TYPES.include?(klass.columns_hash[col].sql_type)
        raise ArgumentError, "#{col} is of a type that cannot be ordered"
      end
    end

    # @param terminal_column [String, nil] the column sorted on when `klass`
    #   is the last hop of the chain, nil when the chain continues past it.
    # Association scopes (e.g. `-> { where(is_original: true) }`) are not
    # applied by the SQL built here, so sorting through one would silently
    # use the wrong rows. Write those with custom().
    def validate_unscoped!(refl)
      parts = [refl]
      if refl.through_reflection
        parts += [refl.through_reflection, refl.source_reflection]
      end
      return if parts.none?(&:scope)

      raise ArgumentError, ":#{refl.name} on #{refl.active_record} has a scope, which sorting does not apply; use custom()"
    end

    def validate_target_class!(klass, terminal_column: nil)
      return unless BLACKLISTED_CLASSES.include?(klass.name)
      return if terminal_column &&
        BLACKLISTED_CLASS_SORTABLE_COLUMNS[klass.name]&.include?(terminal_column.to_s)

      raise ArgumentError, "#{klass} is not reachable for sorting"
    end

    # The LATERAL for a has_many :through joins exactly one through table to
    # one belongs_to source. Other shapes would join the wrong columns, and
    # nested ones skip the User and scope checks for the classes between.
    def validate_through_shape!(refl)
      thr = refl.through_reflection
      src = refl.source_reflection
      shape =
        if thr.through_reflection || src.through_reflection
          'a nested :through'
        elsif !%i[has_many has_one].include?(thr.macro) || thr.polymorphic?
          "through a #{thr.macro}"
        elsif src.macro != :belongs_to || src.polymorphic?
          "a #{src.polymorphic? ? 'polymorphic ' : ''}#{src.macro} source"
        end
      return if shape.nil?

      raise ArgumentError, "has_many :through :#{refl.name} on #{refl.active_record} is #{shape}, which is not generically sortable; use custom()"
    end

    # `type IN (...)` for klass and its STI subclasses, as the association
    # itself selects them.
    def type_condition_sql(klass, table_alias)
      names = ([klass] + klass.descendants).map(&:sti_name).uniq
      "#{table_alias}.#{klass.inheritance_column} IN (#{names.map { |n| quote(n) }.join(', ')})"
    end

    # Postgres truncates identifiers past 63 bytes, which could make two long
    # aliases equal again, so long ones end in a digest instead.
    def sort_alias(parts)
      name = ['sort', *parts].join('_')
      return name if name.length <= 63

      "#{name[0, 50]}_#{Digest::MD5.hexdigest(name)[0, 12]}"
    end

    # Orders query by the SQL expression, NULLS LAST. Built as an Arel node:
    # a string ORDER BY makes Rails add the table names it contains to
    # references_values, and a caller's later `includes` then switches to a
    # slow JOIN-based eager load. Use this for every sort key.
    def order_by_sql(query, expr, dir)
      node = Arel.sql(expr)
      query.order((dir == :desc ? node.desc : node.asc).nulls_last)
    end

    def quote(value) = ActiveRecord::Base.connection.quote(value)
  end
end
