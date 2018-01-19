require 'rails_helper'

RSpec.describe ProtocolRelationshipsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/protocol_relationships').to route_to('protocol_relationships#index')
    end

    it 'routes to #new' do
      expect(get: '/protocol_relationships/new').to route_to('protocol_relationships#new')
    end

    it 'routes to #show' do
      expect(get: '/protocol_relationships/1').to route_to('protocol_relationships#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/protocol_relationships/1/edit').to route_to('protocol_relationships#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/protocol_relationships').to route_to('protocol_relationships#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/protocol_relationships/1').to route_to('protocol_relationships#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/protocol_relationships/1').to route_to('protocol_relationships#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/protocol_relationships/1').to route_to('protocol_relationships#destroy', id: '1')
    end

  end
end
