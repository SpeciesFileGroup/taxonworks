require 'rails_helper'

describe 'geographic_areas/show', :type => :view do
  before(:each) do
    @geographic_area = assign(:geographic_area,
                              stub_model(GeographicArea,
                                         :name                 => 'Area 51',
                                         :parent_id            => 1,
                                         :geographic_area_type => stub_model(GeographicAreaType,
                                                                             name: 'Black Ops Zone'),
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
    expect(rendered).to match(/Area 51/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Black Ops Zone/)
    expect(rendered).to match(/AA/)
    expect(rendered).to match(/AAA/)
    expect(rendered).to match(/Someplace/)
    expect(rendered).to match(/Tdwg/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/0/)
    expect(rendered).to match(/0/)
    expect(rendered).to match(/12/)
    expect(rendered).to match(/13/)
  end
end
