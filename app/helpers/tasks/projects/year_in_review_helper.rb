# Helpers for the Year in Review task dashboard.
# Provides data gathering methods using raw SQL for performance.
#
# @author Claude (>50% of code)
module Tasks::Projects::YearInReviewHelper

  # Tables to exclude from the year in review report (indexing/cache tables).
  EXCLUDED_TABLE_PATTERNS = [/cached|pinboard/i].freeze

  # Tables to include in the year in review report.
  # Based on Project#MANIFEST plus User and Project, excluding indexing tables.
  YEAR_IN_REVIEW_TABLES = (Project::MANIFEST + %w{User Project}).uniq.reject { |t|
    EXCLUDED_TABLE_PATTERNS.any? { |pattern| t.match?(pattern) }
  }.freeze

  # Tables only shown in the admin (cross-project) version.
  ADMIN_ONLY_TABLES = %w{User Project}.freeze

  # Returns all data for the year in review dashboard.
  #
  # @param year [Integer] the calendar year to report on
  # @param project_id [Integer] the project to scope data to (nil for non-project tables)
  # @return [Hash] structured data for all graphs
  def year_in_review_data(year, project_id)
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    table_data = []

    YEAR_IN_REVIEW_TABLES.each do |table_name|
      # Skip admin-only tables when scoped to a project
      next if project_id.present? && ADMIN_ONLY_TABLES.include?(table_name)

      klass = table_name.safe_constantize
      next unless klass
      next unless klass.respond_to?(:table_name)

      actual_table_name = klass.table_name
      next unless table_has_timestamps?(actual_table_name)

      data = calculate_table_stats(
        klass: klass,
        table_name: actual_table_name,
        start_date: start_date,
        end_date: end_date,
        project_id: project_id
      )

      # Exclude tables with zero created and zero updated delta
      next if data[:created_count] == 0 && data[:updated_delta] == 0

      table_data << data
    end

    {
      metadata: {
        year: year,
        project_id: project_id,
        generated_at: Time.current
      },
      tables: table_data,
      graph1: build_graph1_data(table_data),
      graph2: build_graph2_data(table_data),
      graph3: build_graph3_data(table_data),
      graph4: build_graph4_data(table_data)
    }
  end

  # Returns available years for the dropdown selector.
  #
  # @param project_id [Integer, nil] if nil, queries across all projects
  # @return [Array<Integer>] years in descending order
  def available_years_for_review(project_id)
    # Find the earliest created_at across project-scoped tables
    earliest_year = nil

    %w{Otu TaxonName CollectionObject}.each do |table_name|
      klass = table_name.safe_constantize
      next unless klass

      result = if klass.column_names.include?('project_id') && project_id.present?
        klass.where(project_id: project_id).minimum(:created_at)
      else
        klass.minimum(:created_at)
      end

      if result && (earliest_year.nil? || result.year < earliest_year)
        earliest_year = result.year
      end
    end

    earliest_year ||= Time.current.year
    (earliest_year..Time.current.year).to_a.reverse
  end

  private

  # Check if a table has created_at and updated_at columns
  def table_has_timestamps?(table_name)
    columns = ActiveRecord::Base.connection.columns(table_name).map(&:name)
    columns.include?('created_at') && columns.include?('updated_at')
  end

  # Check if a table is project-scoped
  def table_is_project_scoped?(klass)
    klass.column_names.include?('project_id')
  end

  # Check if a table has housekeeping user columns
  def table_has_housekeeping_users?(klass)
    klass.column_names.include?('created_by_id') && klass.column_names.include?('updated_by_id')
  end

  # Calculate all statistics for a single table
  # @param project_id [Integer, nil] if nil, queries across all projects
  def calculate_table_stats(klass:, table_name:, start_date:, end_date:, project_id:)
    is_project_scoped = table_is_project_scoped?(klass)
    has_housekeeping = table_has_housekeeping_users?(klass)

    # Only add project clause if project_id is provided and table has project_id column
    project_clause = (is_project_scoped && project_id.present?) ? "AND project_id = #{project_id.to_i}" : ""

    # Total created in target year
    created_count = execute_count_sql(<<~SQL)
      SELECT COUNT(*)
      FROM #{table_name}
      WHERE created_at >= '#{start_date}'
        AND created_at <= '#{end_date} 23:59:59'
        #{project_clause}
    SQL

    # Total updated in target year
    updated_count = execute_count_sql(<<~SQL)
      SELECT COUNT(*)
      FROM #{table_name}
      WHERE updated_at >= '#{start_date}'
        AND updated_at <= '#{end_date} 23:59:59'
        #{project_clause}
    SQL

    # Delta: updated - created (records updated but not created this year)
    updated_delta = [updated_count - created_count, 0].max

    # All time count (up to and including target year)
    all_time_count = execute_count_sql(<<~SQL)
      SELECT COUNT(*)
      FROM #{table_name}
      WHERE created_at <= '#{end_date} 23:59:59'
        #{project_clause}
    SQL

    # Percentage new vs all time
    percent_new = all_time_count > 0 ? (created_count.to_f / all_time_count * 100).round(2) : 0.0

    # Unique created_by_id and updated_by_id counts
    unique_created_by = 0
    unique_updated_by = 0

    if has_housekeeping
      unique_created_by = execute_count_sql(<<~SQL)
        SELECT COUNT(DISTINCT created_by_id)
        FROM #{table_name}
        WHERE created_at >= '#{start_date}'
          AND created_at <= '#{end_date} 23:59:59'
          #{project_clause}
      SQL

      unique_updated_by = execute_count_sql(<<~SQL)
        SELECT COUNT(DISTINCT updated_by_id)
        FROM #{table_name}
        WHERE updated_at >= '#{start_date}'
          AND updated_at <= '#{end_date} 23:59:59'
          #{project_clause}
      SQL
    end

    # Average time between creation and update (in days)
    avg_update_delta_days = calculate_avg_update_delta(
      table_name: table_name,
      start_date: start_date,
      end_date: end_date,
      project_clause: project_clause
    )

    {
      table_name: table_name,
      display_name: klass.name.underscore.humanize.pluralize,
      model_name: klass.name,
      created_count: created_count,
      updated_count: updated_count,
      updated_delta: updated_delta,
      all_time_count: all_time_count,
      percent_new: percent_new,
      unique_created_by: unique_created_by,
      unique_updated_by: unique_updated_by,
      avg_update_delta_days: avg_update_delta_days,
      is_project_scoped: is_project_scoped
    }
  end

  # Calculate average days between creation and update for records created in the target year
  def calculate_avg_update_delta(table_name:, start_date:, end_date:, project_clause:)
    result = ActiveRecord::Base.connection.execute(<<~SQL)
      SELECT AVG(EXTRACT(EPOCH FROM (updated_at - created_at)) / 86400.0) as avg_days
      FROM #{table_name}
      WHERE created_at >= '#{start_date}'
        AND created_at <= '#{end_date} 23:59:59'
        AND updated_at > created_at
        #{project_clause}
    SQL

    avg = result.first&.fetch('avg_days', nil)
    avg.nil? ? 0.0 : avg.to_f.round(2)
  end

  # Execute a count SQL query and return the integer result
  def execute_count_sql(sql)
    result = ActiveRecord::Base.connection.execute(sql)
    result.first['count'].to_i
  end

  # Graph 1: Stacked bar graph with created and updated delta
  # Sorted descending by sum of created + delta
  def build_graph1_data(table_data)
    sorted = table_data.sort_by { |t| -(t[:created_count] + t[:updated_delta]) }

    {
      labels: sorted.map { |t| t[:display_name] },
      datasets: [
        {
          label: 'Created',
          data: sorted.map { |t| t[:created_count] },
          backgroundColor: sorted.map.with_index { |_, i| graph_color(i, 0.8) }
        },
        {
          label: 'Updated (delta)',
          data: sorted.map { |t| t[:updated_delta] },
          backgroundColor: sorted.map.with_index { |_, i| graph_color(i, 0.5) }
        }
      ]
    }
  end

  # Graph 2: Percentage growth per table
  # Sorted descending by percent_new
  def build_graph2_data(table_data)
    sorted = table_data.sort_by { |t| -t[:percent_new] }

    {
      labels: sorted.map { |t| t[:display_name] },
      datasets: [
        {
          label: '% New This Year',
          data: sorted.map { |t| t[:percent_new] },
          backgroundColor: sorted.map.with_index { |_, i| graph_color(i, 0.7) }
        }
      ]
    }
  end

  # Graph 3: Scatter plot of normalized created/updated vs unique users
  # X-axis: normalized created+updated count (0-1)
  # Y-axis: normalized unique users count (0-1)
  def build_graph3_data(table_data)
    return { datasets: [] } if table_data.empty?

    # Calculate totals for normalization
    max_records = table_data.map { |t| t[:created_count] + t[:updated_delta] }.max.to_f
    max_users = table_data.map { |t| t[:unique_created_by] + t[:unique_updated_by] }.max.to_f

    max_records = 1.0 if max_records == 0
    max_users = 1.0 if max_users == 0

    points = table_data.map.with_index do |t, i|
      record_total = t[:created_count] + t[:updated_delta]
      user_total = t[:unique_created_by] + t[:unique_updated_by]

      {
        x: (record_total / max_records).round(3),
        y: (user_total / max_users).round(3),
        label: t[:display_name]
      }
    end

    {
      datasets: [
        {
          label: 'Tables',
          data: points,
          backgroundColor: table_data.map.with_index { |_, i| graph_color(i, 0.7) },
          pointRadius: 8
        }
      ]
    }
  end

  # Graph 4: Normalized average update delta (time between creation and update)
  # Sorted descending
  def build_graph4_data(table_data)
    # Filter to tables with non-zero delta
    with_delta = table_data.select { |t| t[:avg_update_delta_days] > 0 }
    return { labels: [], datasets: [] } if with_delta.empty?

    max_delta = with_delta.map { |t| t[:avg_update_delta_days] }.max.to_f
    max_delta = 1.0 if max_delta == 0

    sorted = with_delta.sort_by { |t| -t[:avg_update_delta_days] }

    {
      labels: sorted.map { |t| t[:display_name] },
      datasets: [
        {
          label: 'Avg Days Between Create/Update (normalized)',
          data: sorted.map { |t| (t[:avg_update_delta_days] / max_delta).round(3) },
          backgroundColor: sorted.map.with_index { |_, i| graph_color(i, 0.7) },
          raw_values: sorted.map { |t| t[:avg_update_delta_days] }
        }
      ]
    }
  end

  # Generate a color for graph elements based on index
  # Uses HSL color space for visually distinct colors
  def graph_color(index, alpha = 1.0)
    hue = (index * 137.508) % 360  # Golden angle approximation for good distribution
    "hsla(#{hue.round}, 70%, 50%, #{alpha})"
  end

end
