class Tasks::Nomenclature::OriginalCombinationController < ApplicationController
  include TaskControllerConfiguration

  def edit
    @taxon_name = TaxonName.find(params[:taxon_name_id])
    @original_combination_relations = @taxon_name.original_combination_relationships_and_stubs
  end

  def update
    @taxon_name = TaxonName.find(params[:taxon_name_id])
    if @taxon_name.update(combination_params)
      flash[:notice] = "Successfully updated the original combination." 
      redirect_to @taxon_name.metamorphosize 
    else
      flash[:notice] = "The original combination information was NOT updated."
      redirect_to edit_protonym_original_combination_task_path(@taxon_name)
    end

  end

  protected

  def combination_params
    params.require(:taxon_name).permit(related_taxon_name_relationships_attributes: [:type, :subject_taxon_name_id, :_destroy, :id] )
  end

end
