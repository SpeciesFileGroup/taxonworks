class Tasks::Dwc::CompactController < ApplicationController
  include TaskControllerConfiguration

  MAX_ROWS = 5000

  def index
  end

  # POST /tasks/dwc/compact/compact.json
  def compact
    q = ::Queries::DwcOccurrence::Filter.new(params)
    filter_params = q.params

    scope = q.all
      .where(project_id: sessions_current_project_id)
      .select(::DwcOccurrence.target_columns)
      .limit(MAX_ROWS)

    tempfile = ::Export::CSV.copy_table(scope)
    tsv_string = tempfile.read
    tempfile.close!

    table = Utilities::DarwinCore::Table.new(tsv_string:)
    preview = params[:preview] == 'true' || params[:preview] == true

    rows_compacted = Utilities::DarwinCore::Summary.count_rows_compacted(table.rows)

    table.compact(by: :catalog_number, preview:)

    skipped = table.skipped_rows
    skipped_individual_count = skipped.sum { |r| r['individualCount'].to_i }

    all_rows = table.rows + skipped

    pre_1700_rows = all_rows.select { |r| Utilities::DarwinCore::Summary.year_before_1700?(r['eventDate']) }
    pre_1700_individual_count = pre_1700_rows.sum { |r| r['individualCount'].to_i }

    render json: {
      headers: Utilities::DarwinCore::Summary.ordered_headers(table.headers),
      rows: table.rows,
      all_rows:,
      errors: table.errors,
      filter_params:,
      meta: {
        total_rows: table.rows.size,
        preview:,
        rows_compacted:,
        without_catalog_number_rows: skipped.size,
        without_catalog_number_individual_count: skipped_individual_count,
        pre_1700_rows: pre_1700_rows.size,
        pre_1700_individual_count:
      }
    }
  end

end
