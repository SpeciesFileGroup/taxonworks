require 'fileutils'
require 'csv'
require 'set'

namespace :tw do
  namespace :audit do

    # Scan project-scoped tables for foreign keys that point at rows in a
    # different project. Legitimate cross-project references (to community
    # models like Repository, Source, Person) are skipped.
    #
    #   rake tw:audit:cross_project_references
    #   rake tw:audit:cross_project_references PROJECT_ID=7
    #
    # Env:
    #   PROJECT_ID  optional; restricts *source* rows to a single project.
    #               Target project is unconstrained (that's the whole point).
    #   OUT         optional explicit output path.
    desc 'Report project-scoped rows whose FKs point at rows in a different project. PROJECT_ID=<id>, OUT=<path>.'
    task cross_project_references: [:environment] do
      Rails.application.eager_load!

      project_id_filter = ENV['PROJECT_ID'].presence&.to_i
      out_path = ENV['OUT'].presence ||
        Rails.root.join(
          'tmp', 'project_audit',
          "cross_references_#{Time.now.strftime('%Y%m%d_%H%M%S')}.tsv"
        ).to_s

      FileUtils.mkdir_p(File.dirname(out_path))

      conn = ActiveRecord::Base.connection
      project_scoped = ApplicationEnumeration.project_data_classes
      project_scoped_tables = project_scoped.map(&:table_name).to_set

      violations = []
      summary = Hash.new(0)

      check = lambda do |src_klass, tgt_klass, association_name, fk_column, type_column: nil, type_value: nil|
        src_table = src_klass.table_name
        tgt_table = tgt_klass.table_name

        where_extra = []
        where_extra << "src.#{conn.quote_column_name(type_column)} = #{conn.quote(type_value)}" if type_column
        where_extra << "src.project_id = #{project_id_filter.to_i}" if project_id_filter

        sql = <<~SQL
          SELECT src.id AS src_id, src.project_id AS src_project,
                 tgt.id AS tgt_id, tgt.project_id AS tgt_project
          FROM #{conn.quote_table_name(src_table)} src
          JOIN #{conn.quote_table_name(tgt_table)} tgt
            ON src.#{conn.quote_column_name(fk_column)} = tgt.id
          WHERE src.project_id IS NOT NULL
            AND tgt.project_id IS NOT NULL
            AND src.project_id <> tgt.project_id
            #{where_extra.map { |c| "AND #{c}" }.join("\n    ")}
        SQL

        begin
          result = conn.exec_query(sql)
        rescue ActiveRecord::StatementInvalid => e
          warn "  ! skipped #{src_klass.name}##{association_name} → #{tgt_klass.name}: #{e.message.lines.first&.strip}"
          return
        end

        result.each do |row|
          violations << [
            src_klass.name, row['src_id'], row['src_project'],
            association_name.to_s,
            tgt_klass.name, row['tgt_id'], row['tgt_project']
          ]
          summary[[src_klass.name, association_name.to_s]] += 1
        end
      end

      seen_tables = Set.new
      project_scoped.sort_by(&:name).each do |src_klass|
        next if seen_tables.include?(src_klass.table_name)
        seen_tables << src_klass.table_name

        src_cols = src_klass.column_names
        puts "→ #{src_klass.name}"

        src_klass.reflect_on_all_associations(:belongs_to).each do |ref|
          fk_column = ref.foreign_key.to_s
          next unless src_cols.include?(fk_column)

          if ref.polymorphic?
            type_column = ref.foreign_type.to_s
            next unless src_cols.include?(type_column)

            type_sql = <<~SQL
              SELECT DISTINCT #{conn.quote_column_name(type_column)} AS t
              FROM #{conn.quote_table_name(src_klass.table_name)}
              WHERE #{conn.quote_column_name(type_column)} IS NOT NULL
                AND #{conn.quote_column_name(fk_column)} IS NOT NULL
            SQL
            types = conn.exec_query(type_sql).map { |r| r['t'] }.compact

            types.each do |type_name|
              tgt_klass = type_name.safe_constantize
              next unless tgt_klass.is_a?(Class) && tgt_klass < ApplicationRecord
              next unless project_scoped_tables.include?(tgt_klass.table_name)

              check.call(src_klass, tgt_klass, ref.name, fk_column,
                         type_column: type_column, type_value: type_name)
            end
          else
            tgt_klass = begin
              ref.klass
            rescue NameError
              nil
            end
            next unless tgt_klass
            next unless project_scoped_tables.include?(tgt_klass.table_name)

            check.call(src_klass, tgt_klass, ref.name, fk_column)
          end
        end
      end

      headers = %w[source_model source_id source_project association target_model target_id target_project]
      CSV.open(out_path, 'w', col_sep: "\t") do |csv|
        csv << headers
        violations.each { |row| csv << row }
      end

      puts
      if violations.empty?
        puts 'No cross-project references found.'
      else
        puts "Found #{violations.size} cross-project references. Wrote to #{out_path}"
        puts
        puts 'Summary (source_model / association → count):'
        summary.sort_by { |_, n| -n }.each do |(model, assoc), n|
          puts "  #{model}##{assoc}: #{n}"
        end
      end

      exit(violations.empty? ? 0 : 1) if ENV['EXIT_NONZERO_ON_VIOLATION'] == 'true'
    end

  end
end
