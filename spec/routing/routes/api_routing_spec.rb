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
			expect(get('/api/v1/images/1')).to route_to("images#show", :id => "1", :format => :json)
		end
  end
end