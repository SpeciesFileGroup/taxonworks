require 'rails_helper'

RSpec.describe OriginRelationshipsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/origin_relationships').to route_to('origin_relationships#index')
    end

    it 'routes to #new' do
      expect(get: '/origin_relationships/new').to route_to('origin_relationships#new')
    end

    it 'routes to #show' do
      expect(get: '/origin_relationships/1').to route_to('origin_relationships#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/origin_relationships/1/edit').to route_to('origin_relationships#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/origin_relationships').to route_to('origin_relationships#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/origin_relationships/1').to route_to('origin_relationships#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/origin_relationships/1').to route_to('origin_relationships#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/origin_relationships/1').to route_to('origin_relationships#destroy', id: '1')
    end

  end
end
