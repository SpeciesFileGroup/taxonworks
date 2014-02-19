TaxonWorks::Application.routes.draw do
  resources :biocuration_classes
  resources :biocuration_classifications
  resources :collecting_events
  resources :collection_objects
  resources :controlled_vocabulary_terms
  resources :identifiers
  resources :namespaces
  resources :notes
  resources :otus
  resources :people
  resources :projects
  resources :repositories
  resources :taxon_determinations
  resources :taxon_names
  resources :taxon_name_classifications
  resources :taxon_name_relationships
  resources :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root 'dashboard#index'

  get 'taxon_names/demo'
  get 'taxon_names/marilyn'
#  resources :taxon_names

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
