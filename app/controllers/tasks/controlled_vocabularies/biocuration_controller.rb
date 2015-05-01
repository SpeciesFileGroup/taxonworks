class Tasks::ControlledVocabularies::BiocurationController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_view_variables, only: [:build_collection, :create_biocuration_group, :create_biocuration_class]

  # GET build_biocuration_groups_task_path
  def build_collection
  end

  # POST build_biocuration_group_path
  def build_biocuration_group
    t = Tag.new(params.require(:tag).permit(:keyword_id, :tag_object_type, :tag_object_id))
    t.save
    if t.valid?
      flash[:notice] = "Successfully added bicoruation class '#{t.keyword.name}' to biocuration group '#{t.tag_object.name}'."
    else
      flash[:notice] = 'Failed to add biocuration class to biocuration group.'
    end
    redirect_to build_biocuration_groups_task_path
  end


  def create_biocuration_group
    biocuration_group = BiocurationGroup.new(controlled_vocabulary_term_params)
    if biocuration_group.save
      redirect_to build_biocuration_groups_task_path, notice: "Successfully added biocuration group #{biocuration_group.name}" 
    else
      @new_biocuration_group = biocuration_group
      render 'build_collection' 
    end
  end

  def create_biocuration_class
    biocuration_class = BiocurationClass.new(controlled_vocabulary_term_params)
    if biocuration_class.save
      redirect_to build_biocuration_groups_task_path, notice: "Successfully added biocuration class #{biocuration_class.name}" 
    else
      @new_biocuration_class = biocuration_class
      render 'build_collection' 
    end
  end

  protected 

  def set_view_variables
    @new_biocuration_group  = BiocurationGroup.new
    @new_biocuration_class  = BiocurationClass.new
    @biocuration_groups = BiocurationGroup.with_project_id($project_id).all
    @biocuration_classes = BiocurationClass.with_project_id($project_id)
    @available_biocuration_classes = @biocuration_groups.inject({}) {|hsh, bg| hsh.merge( bg =>  (@biocuration_classes - bg.biocuration_classes) )  }
    @biocuration_classes_without_groups = @biocuration_classes.without_tags 
    @new_tag = Tag.new
  end

  def controlled_vocabulary_term_params
    params.require(:controlled_vocabulary_term).permit(:type, :name, :definition, :uri, :uri_relation)
  end


end
