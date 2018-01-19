require 'rails_helper'

RSpec.describe ObservationMatrixRowsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/observation_matrix_rows').to route_to('observation_matrix_rows#index')
    end

    it 'routes to #show' do
      expect(get: '/observation_matrix_rows/1').to route_to('observation_matrix_rows#show', id: '1')
    end

  end
end
