class Tasks::Otus::FilterController < ApplicationController
  include TaskControllerConfiguration

  def download
    @otus = ::Queries::Otu::Filter.new(params).all

    # See helpers/otus_helper.rb
    send_data helpers.ranked_otu_table(@otus),
      type: 'text',
      filename: "otus_#{DateTime.now}.tsv"
  end

end
