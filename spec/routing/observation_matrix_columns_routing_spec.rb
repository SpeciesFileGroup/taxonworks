require 'rails_helper'

RSpec.describe ObservationMatrixColumnsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/observation_matrix_columns').to route_to('observation_matrix_columns#index')
    end

    it 'routes to #show' do
      expect(get: '/observation_matrix_columns/1').to route_to('observation_matrix_columns#show', id: '1')
    end

  end
end
