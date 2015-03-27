require 'rails_helper'

describe GeoreferencesController, :type => :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get('/georeferences')).to route_to('georeferences#index')
    end

    it 'routes to #list' do
      expect(get('/georeferences/list')).to route_to('georeferences#list')
    end

    it 'routes to #new' do
      expect(get('/georeferences/new')).to route_to('georeferences#new')
    end

    it 'routes to #show' do
      expect(get('/georeferences/1')).to route_to('georeferences#show', :id => '1')
    end

    it 'routes to #destroy' do
      expect(delete('/georeferences/1')).to route_to('georeferences#destroy', :id => '1')
    end

  end
end
