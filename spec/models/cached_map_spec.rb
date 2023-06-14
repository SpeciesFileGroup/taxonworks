require 'rails_helper'

RSpec.describe CachedMap, type: :model do

  let(:cached_map) { CachedMap.new }

  let(:map_json) { '{"type": "Polygon", "coordinates": [[[14.67292, 13.034527, 0], [14.67292, 18.27943, 0], [21.70636, 18.27943, 0], [21.70636, 13.034527, 0], [14.67292, 13.034527, 0]]]}' }

  specify '#geo_json_string 1' do
    cached_map.geo_json_string = map_json
    expect(cached_map.geometry).to be_truthy
  end

  specify '#geo_json_string 2' do
    m = CachedMap.new(geo_json_string: map_json)
    expect(m.geometry).to be_truthy
  end

  specify 'Factory test' do
    expect(FactoryBot.create(:valid_cached_map)).to be_truthy
  end

end
