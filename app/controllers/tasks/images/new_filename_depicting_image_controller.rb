class Tasks::Images::NewFilenameDepictingImageController < ApplicationController
  include TaskControllerConfiguration

  # POST /tasks/images/new_filename_depicting_image/match.json
  def match
    @results = Match::CollectionObject::Identifier.new(
      identifiers: params.permit(identifiers: [])[:identifiers] || [],
      project_id: sessions_current_project_id
    ).call

    @global_ids = CollectionObject
      .where(id: @results.filter_map { |r| r[:collection_object_id] })
      .select(:id, :type)
      .to_h { |o| [o.id, o.to_global_id.to_s] }
  end
end
