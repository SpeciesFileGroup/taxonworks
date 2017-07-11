class PapertrailController < ApplicationController
  before_action :require_sign_in_and_project_selection

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
      new_attributes = params[:attributes]

      if !new_attributes.nil?
        new_attributes.each do |key, value|
          if @object.has_attribute?(key)
            @object.assign_attributes(Hash[key, value])
          end
        end
      end

      if !@object.changed?
        flash[:notice] = "No changes made!"
      elsif @object.save
        flash[:notice] = "Successfully restored!"
      else
        flash[:alert] = "Unsuccessfully restored!"
      end

      json_resp = { "url": papertrail_path(object_type: @object.class, object_id: @object.id) }

      # If the object is a child class of "ControlledVocabularyTerm" then we need to use the
      # type member variable since the class member variable doesn't reflect the new class
      # yet and the type is the correct one thus the link thats generated will be correct
      if ControlledVocabularyTerm > @object.class
        json_resp["url"] = papertrail_path(object_type: @object.type, object_id: @object.id)
      end

      respond_to do |format|
        format.html { redirect_to(papertrail_path(object_type: @object.type, object_id: @object.id)) }
        format.json { render json: json_resp }
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
      if version_index_b <= 0 || version_index_b >= @object.versions.length
        version_index_b = version_index_a;
      end

      # Make version_index_a be an index to the newer version
      # thus if version_index_b is greater than version_index_a
      # we must swap the two values to make version_index_a
      # an index to the newer version
      if version_index_b > version_index_a
        tmp_version_index = version_index_b
        version_index_b = version_index_a
        version_index_a = tmp_version_index
      end

      # version_a will point to the newer version
      # version_b will point to the older version
      version_a = @object.versions[version_index_a]
      version_b = @object.versions[version_index_b]

      @user_new = User.find(version_a.whodunnit).name
      @user_old = User.find(version_b.whodunnit).name
      @attributes_new = version_a.reify.attributes
      @attributes_old = version_b.reify.attributes
      @comparing_current = false

      # If the index for version_a and version_b match it means
      # we're comparing the current version against an older one
      if(version_index_a == version_index_b)
        @user_new = User.find(@object["created_by_id"]).name
        @attributes_new = @object.attributes;
        @comparing_current = true
      end

      @attributes_new = view_context.filter_out_attributes(@attributes_new)
      @attributes_old = view_context.filter_out_attributes(@attributes_old)
      render 'compare'
    end
  end
end
