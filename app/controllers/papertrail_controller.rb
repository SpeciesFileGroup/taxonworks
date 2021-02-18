class PapertrailController < ApplicationController
  before_action :require_sign_in_and_project_selection

  def index
    respond_to do |format|
      format.html {
        redirect_to hub_path, notice: 'You requested a papertrail for nothing.' and return if params[:object_type].blank?
        klass = whitelist_constantize(params.require(:object_type))
        @object = klass.find(params[:object_id])
        record_not_found if invalid_object(@object)
        render :papertrail
      }
      # Oldest is *first*, newest last.
      format.json { @versions = papertrail_versions }
    end
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
    klass = whitelist_constantize(params.require(:object_type))
    @object = klass.find(params[:object_id])

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
        flash[:notice] = 'No changes made!'
      elsif @object.save
        flash[:notice] = 'Successfully restored!'
      else
        flash[:alert] = 'Unsuccessfully restored!'
      end

      json_resp = { "url": papertrail_path(object_type: @object.class.base_class, object_id: @object.id) }

      # If the object is a child class of "ControlledVocabularyTerm" then we need to use the
      # type member variable since the class member variable doesn't reflect the new class
      # yet and the type is the correct one thus the link thats generated will be correct
      if ControlledVocabularyTerm > @object.class
        json_resp['url'] = papertrail_path(object_type: @object.type, object_id: @object.id)
      end

      respond_to do |format|
        format.html { redirect_to(papertrail_path(object_type: @object.type, object_id: @object.id)) }
        format.json { render json: json_resp }
      end
    end
  end

  def compare
    klass = whitelist_constantize(params.require(:object_type))
    @object = klass.find(params.require(:object_id))

    if invalid_object(@object)
      record_not_found
    else
      @result = TaxonWorks::Vendor::Papertrail.compare(@object, compare_params)
      @result ? render('compare') : record_not_found
    end
  end

  protected

  def papertrail_versions
    if o = GlobalID::Locator.locate(params.require(:object_global_id))
      render head 404, "content_type" => 'text/plain' if o.respond_to?(:project_id) && o.project_id != sessions_current_project_id
      o.versions
    else
      []
    end
  end


  def compare_params
    params.permit(:version_a, :version_b)
  end

end
