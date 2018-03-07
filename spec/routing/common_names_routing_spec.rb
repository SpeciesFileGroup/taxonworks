require 'rails_helper'

RSpec.describe CommonNamesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/common_names').to route_to('common_names#index')
    end

    it 'routes to #new' do
      expect(get: '/common_names/new').to route_to('common_names#new')
    end

    it 'routes to #show' do
      expect(get: '/common_names/1').to route_to('common_names#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/common_names/1/edit').to route_to('common_names#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/common_names').to route_to('common_names#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/common_names/1').to route_to('common_names#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/common_names/1').to route_to('common_names#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/common_names/1').to route_to('common_names#destroy', id: '1')
    end

  end
end
