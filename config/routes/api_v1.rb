namespace :api, defaults: {format: :json} do
  namespace :v1 do

    # authentication free
    get '/cite/count_valid_species', to: 'cite#count_valid_species'

    get '/', to: 'base#index'

    # services
    get '/stats', to: 'stats#index'

    get :ping, controller: 'ping'
    get :pingz, controller: 'ping'

    # authenticated by user_token
    defaults authenticate_user: true do
      get '/user_authenticated', to: 'base#index'

      get '/sources', to: '/sources#api_index'
      get '/sources/autocomplete', to: '/sources#autocomplete'
      get '/sources/:id', to: '/sources#api_show'

      get '/people', to: '/people#api_index'
      get '/people/autocomplete', to: '/people#autocomplete'
      get '/people/:id', to: '/people#api_show'
    end

    # authenticated by project token
    defaults authenticate_project: true do
      get '/activity', to: 'stats#activity'
      get '/project_authenticated', to: 'base#index'

      # !@ may not be many things here, doesn't make a lot of sense?!
    end

    defaults authenticate_user: true, authenticate_project: true do
      # authenticated by user and project
      get '/both_authenticated', to: 'base#index'
    end

    defaults authenticate_user_or_project: true do
      get '/otus', to: '/otus#api_index'
      get '/otus/autocomplete', to: '/otus#api_autocomplete'
      get '/otus/:id/inventory/content', to: '/otus#api_content', as: :api_content
      get '/otus/:id/inventory/distribution', to: '/otus#api_distribution', as: :api_distribution
      get '/otus/:id/inventory/taxonomy', to: '/otus#api_taxonomy_inventory', as: :taxonomy_inventory
      get '/otus/:otu_id/inventory/images', to: '/images#api_image_inventory', as: :images_inventory
      get '/otus/:id/inventory/type_material', to: '/otus#api_type_material_inventory', as: :type_material_inventory
      get '/otus/:id/inventory/nomenclature_citations', to: '/otus#api_nomenclature_citations', as: :nomenclature_citations_inventory
      get '/otus/:id', to: '/otus#api_show'

      get '/downloads/:id', to: '/downloads#api_show'
      get '/downloads', to: '/downloads#api_index'
      get '/downloads/:id/file', to: '/downloads#api_file', as: :api_download_file

      get '/dwc_occurrences', to: '/dwc_occurrences#api_index'

      get '/taxon_names', to: '/taxon_names#api_index'
      get '/taxon_names/autocomplete', to: '/taxon_names#autocomplete'
      get '/taxon_names/parse', to: '/taxon_names#parse'
      get '/taxon_names/:id/inventory/summary', to: '/taxon_names#api_summary'
      get '/taxon_names/:id', to: '/taxon_names#api_show'

      get '/taxon_name_classifications', to: '/taxon_name_classifications#api_index'
      get '/taxon_name_classifications/taxon_name_classification_types', to: '/taxon_name_classifications#taxon_name_classification_types'
      get '/taxon_name_classifications/:id', to: '/taxon_name_classifications#api_show'

      get '/taxon_name_relationships', to: '/taxon_name_relationships#api_index'
      get '/taxon_name_relationships/taxon_name_relationship_types', to: '/taxon_name_relationships#taxon_name_relationship_types'
      get '/taxon_name_relationships/:id', to: '/taxon_name_relationships#api_show'

      get '/notes', to: '/notes#api_index'
      get '/notes/:id', to: '/notes#api_show'

      get '/identifiers', to: '/identifiers#api_index'
      get '/identifiers/autocomplete', to: '/identifiers#api_autocomplete'
      get '/identifiers/:id', to: '/identifiers#api_show'

      get '/collecting_events', to: '/collecting_events#api_index'
      get '/collecting_events/autocomplete', to: '/collecting_events#api_autocomplete'
      get '/collecting_events/:id', to: '/collecting_events#api_show'

      get '/collection_objects', to: '/collection_objects#api_index'
      get '/collection_objects/autocomplete', to: '/collection_objects#api_autocomplete'
      get '/collection_objects/:id/dwc', to: '/collection_objects#api_dwc'
      get '/collection_objects/:id', to: '/collection_objects#api_show'

      get '/biological_associations', to: '/biological_associations#api_index'
      get '/biological_associations/:id', to: '/biological_associations#api_show'

      get '/citations', to: '/citations#api_index'
      get '/citations/:id', to: '/citations#api_show'

      get '/contents', to: '/contents#api_index'
      get '/contents/:id', to: '/contents#api_show'

      get '/asserted_distributions', to: '/asserted_distributions#api_index'
      get '/asserted_distributions/:id', to: '/asserted_distributions#api_show'

      get '/data_attributes', to: '/data_attributes#api_index'
      get '/data_attributes/:id', to: '/data_attributes#api_show'

      get '/depictions/:id', to: '/depictions#api_show'

      get '/observations', to: '/observations#api_index'
      get '/observations/:id', to: '/observations#api_show'

      get '/observation_matrices/:observation_matrix_id/key', to: '/tasks/observation_matrices/interactive_key#api_key'
      get '/observation_matrices', to: '/observation_matrices#api_index'
      get '/observation_matrices/:id', to: '/observation_matrices#api_show'

      get '/images', to: '/images#api_index'
      get '/images/:id/file', to: '/images#api_file', as: :image_file
      get '/images/:id', to: '/images#api_show'

      # get '/controlled_vocabulary_terms'
    end

    # Authenticate membership at the data controller level

    # Default response when no route matches
    match '/:path', to: 'base#not_found', via: :all
  end
end


