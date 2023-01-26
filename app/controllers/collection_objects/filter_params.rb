module CollectionObjects
  module FilterParams

    private

    # !! Apply pagination during use
    #    page(params[:page]).per(params[:per] || 500)
    # !! Do not add order() here, it breaks DwC integration
    def filtered_collection_objects
      ::Queries::CollectionObject::Filter.new(params).all
    end
  end

end
