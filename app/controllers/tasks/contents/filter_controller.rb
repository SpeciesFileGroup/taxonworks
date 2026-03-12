class Tasks::Contents::FilterController < ApplicationController
  include TaskControllerConfiguration

  def download
    @contents = ::Queries::Content::Filter.new(params).all
      .order('contents.otu_id, contents.topic_id')

    send_data(
      Export::CSV.generate_csv(
        @contents,
        exclude_columns: %w{updated_by_id created_by_id project_id}
      ),
      type: 'text',
      filename: "contents_#{DateTime.now}.tsv"
    )
  end

end