class Tasks::ControlledVocabularies::BiocurationController < ApplicationController

  def build_collection 
     @biocuration_groups = BiocurationGroup.with_project_id($project_id).all
     @biocuration_classes = BiocurationClass.with_project_id($project_id)
     @biocuration_classes_without_groups = @biocuration_classes.without_tags # BiocurationClass.without_tags.with_project_id($project_id)
     @new_biocuration_group  = BiocurationGroup.new
     @new_biocuration_class  = BiocurationClass.new
     @new_tag = Tag.new
  end


  def build_biocuration_group
    t = Tag.new(params.require(:tag).permit(:keyword_id, :tag_object_type, :tag_object_id))
    t.save
    if t.valid?
      flash[:notice] = 'Added to Group'
    else
      flash[:notice] = 'Failed to add to group'
    end
    redirect_to tasks_controlled_vocabularies_biocuration_build_collection_path 
  end

end
