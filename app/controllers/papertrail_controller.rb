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
      version_id = params[:restore_version_id]

      # The version at index 0 is the version created before something is made,
      # as in the state of the obj before it was created, aka all attributes null
      # thus why index of 1 (when it actually has attributes) is the smallest
      # an index can be for a proper version
      if version_id < 1 || version_id >= @object.versions.length
        record_not_found
      else
        @object = @object.versions[params[:restore_version_id].to_i].reify

        if @object.save
          flash[:notice] = "Successfully restored!"
        else
          flash[:alert] = "Unsuccessfully restored!"
        end

        redirect_to papertrail_path(object_type: @object.class, object_id: @object.id)
      end
    end
  end

  def compare
    @object = params[:object_type].constantize.find(params[:object_id])

    if invalid_object(@object)
      record_not_found
    else
      version_index_a = params[:version_a].to_i;
      version_index_b = params[:version_b].to_i;

      # The version at index 0 is the version created before something is made,
      # as in the state of the obj before it was created, aka all attributes null
      # thus why index of 1 (when it actually has attributes) is the smallest
      # an index can be for a proper version
      if version_index_a < 1 || version_index_a >= @object.versions.length
        record_not_found
        return
      end

      # If version_b index is outside the range treat it as if it means that
      # we should compare the current version to an older version, thus set it 
      # equal to version_a index for simplicity for later on
      if version_index_b < 0 || version_index_b >= @object.versions.length
        version_index_b = version_index_a;
      end

      version_a = @object.versions[version_index_a]
      version_b = @object.versions[version_index_b]

      if version_index_a > version_index_b
        @user_new = User.find(version_a.whodunnit).name
        @user_old = User.find(version_b.whodunnit).name
        @attributes_new = version_a.reify.attributes
        @attributes_old = version_b.reify.attributes
      else
        @user_new = User.find(version_b.whodunnit).name
        @user_old = User.find(version_a.whodunnit).name
        @attributes_new = version_b.reify.attributes
        @attributes_old = version_a.reify.attributes
      end

      @comparing_current = false

      # If the index for version_a and version_b match it means
      # we're comparing the current version against an older one
      if(version_index_a == version_index_b)
        @user_new = User.find(@object["created_by_id"]).name
        @attributes_new = @object.attributes;
        @comparing_current = true
      end

      render 'compare'
    end
  end

end
