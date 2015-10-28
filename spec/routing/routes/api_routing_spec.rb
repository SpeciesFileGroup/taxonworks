require 'rails_helper'

describe ApiController, :type => :routing do
  describe 'routing' do

    it 'routes /api/ to #index with JSON format' do
      expect(get('/api/')).to route_to('api#index', :format => :json)
    end

    it 'routes /api/v1/ to #index with JSON format' do
      expect(get('/api/v1')).to route_to('api#index', :format => :json)
    end

    it 'routes /api/v1/images/{id} to images#show with JSON format' do
			expect(get('/api/v1/images/1')).to route_to('images#show', :id => '1', :format => :json)
		end

    it 'does not route /api/v1/images/foo to images#show' do
      expect(get('/api/v1/images/foo')).not_to route_to('images#show', :id => 'foo', :format => :json)
    end

    it 'routes /api/v1/collection_objects/{:id} to collection_objects#show' do
      expect(get('/api/v1/collection_objects/1')).to route_to('collection_objects#show', :id => '1', :format => :json)
    end

    xit 'does not route /api/v1/collection_objects/foo to collection_objects#show' do
      expect(get('/api/v1/collection_objects/foo')).not_to route_to('collection_objects#show', :id => 'foo', :format => :json)
    end
 
    xit 'routes /api/v1/collection_objects/identified_by to collection_objects#identified_by' do
      expect(get('/api/v1/collection_objects/identified_by')).to route_to('collection_objects#identified_by', :format => :json)
    end
  end
end