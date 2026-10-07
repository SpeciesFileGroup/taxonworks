require 'csv'
require 'time'

module Support

  # Compare two TSVs written by `rake tw:audit:project_stats` and summarize
  # what changed between them: row count changes per project and table,
  # tables emptied or newly populated, projects whose data appeared or
  # disappeared, and tables whose rows changed without a change in count.
  #
  # The snapshots hold only count, max_id, max_created_at and max_updated_at,
  # so "signals" report only what those prove:
  #   :inserted - max_id grew
  #   :deleted  - count fell, or rows were inserted without the count rising
  #   :updated  - max_updated_at got later without any inserts (deleting
  #               the newest rows moves it earlier, which is not an update)
  #
  # Written mostly by Claude.
  class ProjectStatsDiff

    HEADERS = %w[project_id project_name model table count max_created_at max_updated_at max_id].freeze

    Change = Struct.new(:project_id, :project_name, :model, :table, :start_row, :end_row, keyword_init: true) do
      def start_count
        start_row ? start_row['count'].to_i : 0
      end

      def end_count
        end_row ? end_row['count'].to_i : 0
      end

      def delta
        end_count - start_count
      end

      # @return [Float, nil] nil when the start count is 0
      def percent
        return nil if start_count.zero?
        (delta * 100.0 / start_count).round(1)
      end

      # @return [Symbol] :emptied, :new, :count or :same_count
      def kind
        if start_count > 0 && end_count.zero?
          :emptied
        elsif start_count.zero? && end_count > 0
          :new
        elsif delta != 0
          :count
        else
          :same_count
        end
      end

      def signals
        inserted = value(end_row, 'max_id').to_i > value(start_row, 'max_id').to_i
        s = []
        s << :inserted if inserted
        s << :deleted if delta < 0 || (inserted && delta <= 0 && end_count > 0)
        s << :updated if !inserted && later?(time(start_row, 'max_updated_at'), time(end_row, 'max_updated_at'))
        s
      end

      def changed?
        delta != 0 || signals.any?
      end

      private

      def value(row, column)
        row && row[column].to_s
      end

      def time(row, column)
        v = value(row, column)
        v.nil? || v.empty? ? nil : Time.parse(v)
      end

      def later?(start_time, end_time)
        !end_time.nil? && (start_time.nil? || end_time > start_time)
      end
    end

    attr_reader :start_label, :end_label, :changes, :unchanged_count

    # @param start_path [String]
    # @param end_path [String]
    # @return [ProjectStatsDiff]
    def self.from_files(start_path, end_path, project_id: nil)
      new(
        read(start_path), read(end_path),
        start_label: start_path, end_label: end_path, project_id:
      )
    end

    # @return [Array of Hash] one Hash per TSV row, keyed by HEADERS
    def self.read(path)
      raise ArgumentError, "File not found: #{path}" unless File.exist?(path)

      table = CSV.read(path, col_sep: "\t", headers: true)
      unless table.headers == HEADERS
        raise ArgumentError, "#{path} has unexpected headers #{table.headers.inspect}, expected #{HEADERS.inspect}"
      end

      table.map(&:to_h)
    end

    # @param start_rows [Array of Hash] rows keyed by HEADERS
    # @param end_rows [Array of Hash]
    # @param project_id [Integer, nil] limit the diff to this project
    def initialize(start_rows, end_rows, start_label: 'start', end_label: 'end', project_id: nil)
      @start_label = start_label
      @end_label = end_label

      start_by_key = index(start_rows, project_id)
      end_by_key = index(end_rows, project_id)

      all = (start_by_key.keys | end_by_key.keys).map do |key|
        s = start_by_key[key]
        e = end_by_key[key]
        Change.new(
          project_id: key.first,
          project_name: (e || s)['project_name'],
          model: (e || s)['model'],
          table: key.last,
          start_row: s,
          end_row: e
        )
      end

      @changes = all.select(&:changed?)
      @unchanged_count = all.size - @changes.size
      @project_names = { start: names(start_rows), end: names(end_rows) }
      @start_totals = project_totals(start_by_key.values)
      @end_totals = project_totals(end_by_key.values)
    end

    def rows_added
      changes.sum { |c| c.delta > 0 ? c.delta : 0 }
    end

    def rows_removed
      changes.sum { |c| c.delta < 0 ? -c.delta : 0 }
    end

    # @return [Hash] project_id => { name:, rows:, tables: } for projects with rows only at the start
    def projects_gone
      @start_totals.reject { |id, _| @end_totals.key?(id) }
    end

    # @return [Hash] project_id => { name:, rows:, tables: } for projects with rows only at the end
    def projects_added
      @end_totals.reject { |id, _| @start_totals.key?(id) }
    end

    # @return [Hash] project_id => [start name, end name]
    def projects_renamed
      @project_names[:start].each_with_object({}) do |(id, name), h|
        end_name = @project_names[:end][id]
        h[id] = [name, end_name] if end_name && end_name != name
      end
    end

    # @return [String] a human readable summary
    def report
      out = []
      by_kind = changes.group_by(&:kind)

      out << 'Project stats diff'
      out << "  start: #{start_label}"
      out << "  end:   #{end_label}"
      out << ''

      out << 'Summary'
      out << "  #{changes.size} of #{changes.size + unchanged_count} project/table pairs changed"
      out << "  rows: #{signed(rows_added)} added, #{signed(-rows_removed)} removed, net #{signed(rows_added - rows_removed)}"
      out << "  #{by_kind.fetch(:emptied, []).size} emptied, #{by_kind.fetch(:new, []).size} newly populated, " \
             "#{projects_gone.size} projects with no rows left, #{projects_added.size} projects added"
      out << ''

      if changes.empty? && projects_renamed.empty?
        out << 'No changes.'
        return out.join("\n") + "\n"
      end

      project_section(out, 'Projects with no rows left', projects_gone)
      project_section(out, 'Projects added', projects_added)

      if projects_renamed.any?
        out << 'Projects renamed'
        projects_renamed.sort.each { |id, (from, to)| out << "  [#{id}] #{from} -> #{to}" }
        out << ''
      end

      flat_section(out, 'Emptied', by_kind[:emptied])
      flat_section(out, 'Newly populated', by_kind[:new])

      grouped_section(out, 'Count changes', by_kind[:count], %w[table model start end delta % signals], [2, 3, 4, 5]) do |c|
        [c.table, c.model, delimit(c.start_count), delimit(c.end_count), signed(c.delta), percent(c), c.signals.join(', ')]
      end

      grouped_section(out, 'Same count, rows changed', by_kind[:same_count], %w[table model count signals], [2]) do |c|
        [c.table, c.model, delimit(c.end_count), c.signals.join(', ')]
      end

      out << 'Signals state only what the snapshots prove: inserted = max_id grew; ' \
             'deleted = count fell, or did not rise despite inserts; updated = max_updated_at got later with no inserts.'

      out.join("\n") + "\n"
    end

    private

    def index(rows, project_id)
      rows.each_with_object({}) do |r, h|
        pid = r['project_id'].to_s.empty? ? nil : r['project_id'].to_i
        next if project_id && pid != project_id
        h[[pid, r['table']]] = r
      end
    end

    def names(rows)
      rows.each_with_object({}) do |r, h|
        next if r['project_id'].to_s.empty?
        h[r['project_id'].to_i] = r['project_name']
      end
    end

    def project_totals(rows)
      rows.each_with_object({}) do |r, h|
        next if r['project_id'].to_s.empty? || r['count'].to_i.zero?
        t = (h[r['project_id'].to_i] ||= { name: r['project_name'], rows: 0, tables: 0 })
        t[:rows] += r['count'].to_i
        t[:tables] += 1
      end
    end

    def project_label(id, name)
      id ? "[#{id}] #{name}" : '[-] not project-scoped'
    end

    def project_section(out, title, projects)
      return if projects.empty?
      out << title
      projects.sort.each do |id, t|
        out << "  #{project_label(id, t[:name])}  (#{delimit(t[:rows])} rows across #{t[:tables]} #{t[:tables] == 1 ? 'table' : 'tables'})"
      end
      out << ''
    end

    def flat_section(out, title, changes)
      return if changes.nil? || changes.empty?
      out << title
      rows = sort_by_project(changes).map do |c|
        [project_label(c.project_id, c.project_name), c.table, c.model, delimit(c.start_count), delimit(c.end_count)]
      end
      out.concat(columns(%w[project table model start end], rows, right: [3, 4]))
      out << ''
    end

    def grouped_section(out, title, changes, headers, right)
      return if changes.nil? || changes.empty?
      out << title
      sort_by_project(changes).group_by { |c| [c.project_id, c.project_name] }.each do |(id, name), cs|
        out << "  #{project_label(id, name)}"
        rows = cs.sort_by { |c| [-c.delta.abs, c.table] }.map { |c| yield(c) }
        out.concat(columns(headers, rows, right:, indent: 4))
      end
      out << ''
    end

    def sort_by_project(changes)
      changes.sort_by { |c| [c.project_id || -1, c.table] }
    end

    def columns(headers, rows, right: [], indent: 2)
      widths = headers.each_index.map { |i| ([headers] + rows).map { |r| r[i].to_s.length }.max }
      ([headers] + rows).map do |r|
        cells = r.each_with_index.map { |v, i| right.include?(i) ? v.to_s.rjust(widths[i]) : v.to_s.ljust(widths[i]) }
        (' ' * indent + cells.join('  ')).rstrip
      end
    end

    def percent(change)
      p = change.percent
      return '' if p.nil?
      sign = change.delta > 0 ? '+' : '-'
      p.zero? ? "#{sign}<0.1%" : "#{sign}#{p.abs}%"
    end

    def delimit(number)
      number.to_s.reverse.scan(/\d{1,3}/).join(',').reverse.prepend(number < 0 ? '-' : '')
    end

    def signed(number)
      number > 0 ? "+#{delimit(number)}" : delimit(number)
    end
  end
end
