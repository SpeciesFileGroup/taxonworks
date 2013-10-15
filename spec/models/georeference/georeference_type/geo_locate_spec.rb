require 'spec_helper'

describe Georeference::GeoreferenceType::GeoLocate do

  before :all do

  end

  context 'on invocation of \'locate\'' do

    specify 'that the locator can do certain things, or not.' do
      geo_locator = Georeference::GeoreferenceType::GeoLocate.new

      geo_locator.locate('usa', 'champaign', 'illinois')

      expect(geo_locator.request).to eq '?country=usa&locality=champaign&state=illinois&dopoly=true'
      expect(geo_locator.geographic_item_id).not_to be_nil
      expect(geo_locator.error_geographic_item_id).not_to be_nil
      expect(geo_locator.error_radius).to eq 7338
    end

  end

end
