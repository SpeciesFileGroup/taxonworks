module CollectionObjects
  module FilterParams

    private

    def filter_params
      f = ::Queries::CollectionObject::Filter.permit(params)
      f.merge(project_id: sessions_current_project_id)
    end

    # !! Apply pagination during use
    #    page(params[:page]).per(params[:per] || 500)
    # !! Do not add order() here, it breaks DwC integration
    def filtered_collection_objects
      ::Queries::CollectionObject::Filter.new(filter_params).all
    end
  end

end
