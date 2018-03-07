require 'rails_helper'

RSpec.describe ConfidencesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/confidences').to route_to('confidences#index')
    end

    it 'routes to #new' do
      expect(get: '/confidences/new').to route_to('confidences#new')
    end

    it 'routes to #show' do
      expect(get: '/confidences/1').to route_to('confidences#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/confidences/1/edit').to route_to('confidences#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/confidences').to route_to('confidences#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/confidences/1').to route_to('confidences#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/confidences/1').to route_to('confidences#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/confidences/1').to route_to('confidences#destroy', id: '1')
    end

  end
end
