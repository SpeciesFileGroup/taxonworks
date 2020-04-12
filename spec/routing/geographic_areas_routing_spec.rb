require 'rails_helper'

describe GeographicAreasController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get('/geographic_areas')).to route_to('geographic_areas#index')
    end

    xit 'routes to #new' do
      expect(get('/geographic_areas/new')).to route_to('geographic_areas#new')
    end

    it 'routes to #show' do
      expect(get('/geographic_areas/1')).to route_to('geographic_areas#show', id: '1')
    end

    xit 'routes to #edit' do
      expect(get('/geographic_areas/1/edit')).to route_to('geographic_areas#edit', id: '1')
    end

    xit 'routes to #create' do
      expect(post('/geographic_areas')).to route_to('geographic_areas#create')
    end

    xit 'routes to #update' do
      expect(put('/geographic_areas/1')).to route_to('geographic_areas#update', id: '1')
    end

    xit 'routes to #destroy' do
      expect(delete('/geographic_areas/1')).to route_to('geographic_areas#destroy', id: '1')
    end

  end
end
