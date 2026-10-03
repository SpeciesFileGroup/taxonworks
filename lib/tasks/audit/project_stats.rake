require 'fileutils'
require 'csv'
require 'set'

namespace :tw do
  namespace :audit do

    # Emit a TSV of per-project record counts and last-touched timestamps per
    # model. Run before and after a mutating operation and `diff` the two TSVs
    # to see which projects/models were touched.
    #
    #   rake tw:audit:project_stats LABEL=pre_import
    #   rake tw:audit:project_stats LABEL=post_import
    #   diff tmp/project_audit/pre_import.tsv tmp/project_audit/post_import.tsv
    #
    # Env:
    #   LABEL  optional filename stem. Falls back to a timestamp.
    #   OUT    optional explicit output path. Overrides LABEL.
    desc 'Emit per-project record counts / max timestamps / max id per model as TSV. LABEL=<name>, OUT=<path>.'
    task project_stats: [:environment] do
      Rails.application.eager_load!

      label = ENV['LABEL'].presence
      out_path = ENV['OUT'].presence ||
        Rails.root.join(
          'tmp', 'project_audit',
          "#{label || "project_stats_#{Time.now.strftime('%Y%m%d_%H%M%S')}"}.tsv"
        ).to_s

      FileUtils.mkdir_p(File.dirname(out_path))

      conn = ActiveRecord::Base.connection
      project_names = Project.pluck(:id, :name).to_h

      headers = %w[project_id project_name model table count max_created_at max_updated_at max_id]
      rows = []
      seen_tables = Set.new

      project_scoped = ApplicationEnumeration.project_data_classes.sort_by(&:name)
      other = (ApplicationEnumeration.superclass_models - project_scoped).sort_by(&:name)

      puts "Auditing #{project_scoped.size} project-scoped and #{other.size} other models..."

      project_scoped.each do |klass|
        table = klass.table_name
        next if seen_tables.include?(table)
        seen_tables << table

        cols = klass.column_names
        select = [
          'project_id',
          'COUNT(*) AS cnt',
          'MAX(id) AS mid',
          cols.include?('created_at') ? 'MAX(created_at) AS mca' : 'NULL AS mca',
          cols.include?('updated_at') ? 'MAX(updated_at) AS mua' : 'NULL AS mua'
        ].join(', ')

        sql = "SELECT #{select} FROM #{conn.quote_table_name(table)} GROUP BY project_id"
        conn.exec_query(sql).each do |r|
          pid = r['project_id']
          rows << [
            pid,
            pid ? project_names[pid] : nil,
            klass.name,
            table,
            r['cnt'],
            r['mca'],
            r['mua'],
            r['mid']
          ]
        end
        print '.'
      end

      other.each do |klass|
        table = klass.table_name
        next if seen_tables.include?(table)
        seen_tables << table

        cols = klass.column_names
        select = [
          'COUNT(*) AS cnt',
          cols.include?('id') ? 'MAX(id) AS mid' : 'NULL AS mid',
          cols.include?('created_at') ? 'MAX(created_at) AS mca' : 'NULL AS mca',
          cols.include?('updated_at') ? 'MAX(updated_at) AS mua' : 'NULL AS mua'
        ].join(', ')

        sql = "SELECT #{select} FROM #{conn.quote_table_name(table)}"
        r = conn.exec_query(sql).first
        rows << [
          nil,
          nil,
          klass.name,
          table,
          r['cnt'],
          r['mca'],
          r['mua'],
          r['mid']
        ]
        print '.'
      end
      puts

      # Stable sort for diff-friendly output: model, then project_id
      # (nulls first so community rows appear at the top of each model's block).
      rows.sort_by! { |row| [row[2], row[0].nil? ? -1 : row[0]] }

      CSV.open(out_path, 'w', col_sep: "\t") do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end

      puts "Wrote #{rows.size} rows to #{out_path}"
    end

  end
end
