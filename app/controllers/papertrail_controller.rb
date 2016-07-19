class PapertrailController < ApplicationController
  before_filter :require_sign_in_and_project_selection

  # GET /papertrail
  def papertrail
    @object = params[:object_type].constantize.find(params[:object_id])
     record_not_found if invalid_object(@object)
  end

  def show
    @version = PaperTrail::Version.find(params[:id])
    @object = @version.item
    if invalid_object(@object) 
      record_not_found
    else
      render 'papertrail'
    end
  end

  def update
    @object = params[:object_type].constantize.find(params[:object_id])

    if invalid_object(@object)
      record_not_found
    else
      @object = @object.versions[params[:restore_version_id].to_i].reify

      if @object.save
        flash[:notice] = "Successfully restored!"
      else
        flash[:alert] = "Unsuccessfully restored!"
      end

      render 'papertrail'
    end
  end

  def compare
    @object = params[:object_type].constantize.find(params[:object_id])

    if invalid_object(@object)
      record_not_found
    else
      version_index_a = params[:version_a].to_i;
      version_index_b = params[:version_b].to_i;

      if version_index_a > version_index_b
        @version_new = @object.versions[params[:version_a].to_i].reify
        @version_old = @object.versions[params[:version_b].to_i].reify
      else
        @version_new = @object.versions[params[:version_b].to_i].reify
        @version_old = @object.versions[params[:version_a].to_i].reify
      end

      render 'compare'
    end
  end

end
