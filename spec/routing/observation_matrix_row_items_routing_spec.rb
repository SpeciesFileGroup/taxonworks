require 'rails_helper'

RSpec.describe ObservationMatrixRowItemsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/observation_matrix_row_items').to route_to('observation_matrix_row_items#index')
    end

    xit 'routes to #new' do
      expect(get: '/observation_matrix_row_items/new').to route_to('observation_matrix_row_items#new')
    end

    it 'routes to #show' do
      expect(get: '/observation_matrix_row_items/1').to route_to('observation_matrix_row_items#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/observation_matrix_row_items/1/edit').to route_to('observation_matrix_row_items#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/observation_matrix_row_items').to route_to('observation_matrix_row_items#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/observation_matrix_row_items/1').to route_to('observation_matrix_row_items#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/observation_matrix_row_items/1').to route_to('observation_matrix_row_items#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/observation_matrix_row_items/1').to route_to('observation_matrix_row_items#destroy', id: '1')
    end

  end
end
