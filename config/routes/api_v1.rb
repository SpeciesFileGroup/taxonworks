namespace :api, defaults: {format: :json} do

  namespace :v1 do

    # authentication free
    get '/', to: 'base#index'

    get :ping, controller: 'ping'
    get :pingz, controller: 'ping'

    # authenticated by user_token
    defaults authenticate_user: true do
      get '/user_authenticated', to: 'base#index'
    end

    # authenticated by project token
    defaults authenticate_project: true do
      get '/project_authenticated', to: 'base#index'


      # !@ may not be many things here, doesn't make a lot of sense?!
    end

    defaults authenticate_user: true, authenticate_project: true do
      # authenticated by user and project
      get '/both_authenticated', to: 'base#index'
    end

    defaults authenticate_user_or_project: true do
      get '/otus', to: '/otus#index'

      get '/taxon_names', to: '/taxon_names#api_index'
      get '/taxon_names/autocomplete', to: '/taxon_names#autocomplete'
      get '/taxon_names/:id', to: '/taxon_names#api_show'
    end

    # Authenticate membership at the data controller level

    # Default response when no route matches
    match '/:path', to: 'base#not_found', via: :all
  end
end


=begin
scope :api, defaults: { format: :html } do
  scope  '/v1' do
    get '/taxon_names/autocomplete',
      to: 'taxon_names#autocomplete'
  end
end

# Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
# lose the autoloading update from the include in this case however)
scope :api, defaults: { format: :json }, constraints: { id: /\d+/ } do
  scope  '/v1' do

    get '/otus',
      to: 'otus#index'

    get '/asserted_distributions',
      to: 'asserted_distributions#index'

    get '/biological_relationships',
      to: 'biological_relationships#index'

    get '/biological_associations',
      to: 'biological_associations#index'

    get '/observation_matrices/:id/row',
      to: 'observation_matrices#row'

    get '/confidence_levels',
      to: 'confidence_levels#index'

    get '/confidences',
      to: 'confidences#index'

    get '/data_attributes',
      to: 'data_attributes#index'

    get '/taxon_names/:id',
      to: 'taxon_names#show'

    get '/observations/:observation_id/notes',
      to: 'notes#index'

    get '/observations/:observation_id/confidences',
      to: 'confidences#index'

    get '/observations/:observation_id/depictions',
      to: 'depictions#index'

    get '/observations/:observation_id/citations',
      to: 'citations#index'

    get '/observations/:id/annotations',
      to: 'observations#annotations'

    get '/descriptors/:id/annotations',
      to: 'descriptors#annotations'

    get '/descriptors/:id',
      to: 'descriptors#show'

    get '/descriptors/:descriptor_id/notes',
      to: 'notes#index'

    get '/descriptors/:descriptor_id/confidences',
      to: 'confidences#index'

    get '/descriptors/:descriptor_id/observations',
      to: 'observations#index'

    get '/descriptors/:descriptor_id/depictions',
      to: 'depictions#index'

    resources :observations, except: [:new, :edit]

    get '/character_states/:id/annotations',
      to: 'character_states#annotations'

    # TODO: DRY
    # Generate shallow routes for annotations based on model properties, like
    # otu_citations GET /otus/:otu_id/citations(.:format) citations#index
    ApplicationEnumeration.data_models.each do |m|
      ::ANNOTATION_TYPES.each do |t|
        if m.send("has_#{t}?")
          n = m.model_name
          match "/#{n.route_key}/:#{n.param_key}_id/#{t}", to: "#{t}#index",  via: :get, constraints: {format: :json}, defaults: {format: :json}
        end
      end
    end

  end
end

# Future consideration - move this to an engine, or include multiple draw files and include (you apparenlty
# lose the autoloading update from the include in this case however)
scope :api, defaults: { format: :json }, constraints: { id: /\d+/ } do
  get '/', controller: :api, action: :index, as: 'api'
  scope  '/v1' do
    get '/',
      to: 'api#index'
    get '/images/:id',
      to: 'images#show',
      as: 'api_v1_image'

    get '/collection_objects/:id/images',
      to: 'collection_objects#images',
      as: 'api_v1_collection_object_images'
    get '/collection_objects/:id/geo_json',
      to: 'collection_objects#geo_json',
      as: 'api_v1_collection_object_geo_json'
    
    get '/collection_objects/by_identifier/:identifier',
      to: 'collection_objects#by_identifier',
      as: 'api_v1_collection_object_by_identifier'

    # TODO: With the separation of images and geo_json, this path is no longer required.
    get '/collection_objects/:id',
      to: 'collection_objects#show',
      as: 'api_v1_collection_object'

    get '/otus/:id/collection_objects',
      to: 'otus#collection_objects',
      as: 'api_v1_otu_collection_objects'
    get '/otus/by_name/:name',
      to: 'otus#by_name',
      as: 'api_v1_otu_by_name'
    # get '/otus/:id', to: 'otus#show'

    get '/descriptors',
      to: 'descriptors#index'

    get '/observations',
      to: 'observations#index'

  end
end
=end
