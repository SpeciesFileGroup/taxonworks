class Tasks::BiologicalAssociations::FilterController < ApplicationController
  include TaskControllerConfiguration

  def download_index
    biological_associations = ::Queries::BiologicalAssociation::Filter.new(params).all

    scope = ::BiologicalAssociationIndex.where(
      biological_association_id: biological_associations.select(:id)
    )

    send_data(
      Export::CSV.generate_csv(
        scope,
        exclude_columns: %w{id project_id created_by_id updated_by_id created_at updated_at rebuild_set
          biological_association_id biological_relationship_id subject_id object_id}
      ),
      type: 'text',
      filename: "biological_associations_index_#{DateTime.now}.tsv"
    )
  end

end