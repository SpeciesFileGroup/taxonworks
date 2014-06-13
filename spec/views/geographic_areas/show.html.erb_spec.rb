require 'spec_helper'

describe 'geographic_areas/show' do
  before(:each) do
    @geographic_area = assign(:geographic_area,
                              stub_model(GeographicArea,
                                         :name                 => 'Name',
                                         :parent_id            => 1,
                                         :geographic_area_type => stub_model(GeographicAreaType,
                                                                             name: 'AreaTypeName'),
                                         :iso_3166_a2          => 'AA',
                                         :iso_3166_a3          => 'AAA',
                                         :data_origin          => 'Someplace',
                                         :tdwgID               => 'Tdwg',
                                         :level0_id            => 1,
                                         :level1_id            => 0,
                                         :level2_id            => 0,
                                         :created_by_id        => 12,
                                         :updated_by_id        => 13
                              ))
    # @geographic_area_type = assign(:geographic_area_type,
    #                                stub_model(GeographicAreaType,
    #                                           :id => 1,
    #                                           :name => 'AreaType')).as_new_record
  end

  it 'renders attributes in <p>' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/AreaTypeName/)
    rendered.should match(/AA/)
    rendered.should match(/AAA/)
    rendered.should match(/Someplace/)
    rendered.should match(/Tdwg/)
    rendered.should match(/1/)
    rendered.should match(/0/)
    rendered.should match(/0/)
    rendered.should match(/12/)
    rendered.should match(/13/)
  end
end
