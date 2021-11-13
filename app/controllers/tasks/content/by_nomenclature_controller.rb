class Tasks::Content::ByNomenclatureController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @taxon_names = TaxonName
      .select('taxon_names.*, taxon_name_hierarchies.generations')
      .that_is_valid
      .with_base_of_rank_class("NomenclaturalRank::Iczn::SpeciesGroup::S")
      .joins(:descendant_hierarchies)
      .where(project_id: sessions_current_project_id)
      .order('taxon_name_hierarchies.generations, taxon_names.cached')
      .distinct

    @topic = Topic.where(project_id: sessions_current_project_id).where(id: params[:topic_id]).first
  end

end
