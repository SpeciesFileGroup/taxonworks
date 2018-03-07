require 'rails_helper'

RSpec.describe ObservationMatricesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/observation_matrices').to route_to('observation_matrices#index')
    end

    it 'routes to #new' do
      expect(get: '/observation_matrices/new').to route_to('observation_matrices#new')
    end

    it 'routes to #show' do
      expect(get: '/observation_matrices/1').to route_to('observation_matrices#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/observation_matrices/1/edit').to route_to('observation_matrices#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/observation_matrices').to route_to('observation_matrices#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/observation_matrices/1').to route_to('observation_matrices#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/observation_matrices/1').to route_to('observation_matrices#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/observation_matrices/1').to route_to('observation_matrices#destroy', id: '1')
    end

  end
end
