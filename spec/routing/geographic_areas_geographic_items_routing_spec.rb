require 'rails_helper'

describe GeographicAreasGeographicItemsController, :type => :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get('/geographic_areas_geographic_items')).to route_to('geographic_areas_geographic_items#index')
    end

    it 'routes to #new' do
      expect(get('/geographic_areas_geographic_items/new')).to route_to('geographic_areas_geographic_items#new')
    end

    it 'routes to #show' do
      expect(get('/geographic_areas_geographic_items/1')).to route_to('geographic_areas_geographic_items#show', :id => '1')
    end

    it 'routes to #edit' do
      expect(get('/geographic_areas_geographic_items/1/edit')).to route_to('geographic_areas_geographic_items#edit', :id => '1')
    end

    it 'routes to #create' do
      expect(post('/geographic_areas_geographic_items')).to route_to('geographic_areas_geographic_items#create')
    end

    it 'routes to #update' do
      expect(put('/geographic_areas_geographic_items/1')).to route_to('geographic_areas_geographic_items#update', :id => '1')
    end

    it 'routes to #destroy' do
      expect(delete('/geographic_areas_geographic_items/1')).to route_to('geographic_areas_geographic_items#destroy', :id => '1')
    end

  end
end
