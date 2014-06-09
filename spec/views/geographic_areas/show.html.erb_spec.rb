require 'spec_helper'

describe 'geographic_areas/show' do
  before(:each) do
    @geographic_area      = assign(:geographic_area,
                                   stub_model(GeographicArea,
                                              :name                    => 'Name',
                                              :parent_id               => 1,
                                              :geographic_area_type_id => 1,
                                              :iso_3166_a2             => 'AA',
                                              :iso_3166_a3             => 'AAA',
                                              :data_origin             => 'Someplace',
                                              :tdwgID                  => 'Tdwg',
                                              :level0_id               => 1,
                                              :level1_id               => 1,
                                              :level2_id               => 1,
                                              :created_by_id           => 12,
                                              :updated_by_id           => 13
                                   ).as_new_record)
    @geographic_area_type = assign(:geographic_area_type,
                                   stub_model(GeographicAreaType,
                                              :id => 1,
                                              :name => 'AreaType'))
  end

  it 'renders attributes in <p>' do
    pending 'reconstruction of the geographic_area/show view or spec'
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
    rendered.should match(/Iso 3166 A2/)
    rendered.should match(/9/)
    rendered.should match(/Iso 3166 A3/)
    rendered.should match(/10/)
    rendered.should match(/Tdwg/)
    rendered.should match(/11/)
    rendered.should match(/Gadm Valid From/)
    rendered.should match(/Gadm Valid To/)
    rendered.should match(/Data Origin/)
    rendered.should match(/Adm0 A3/)
    rendered.should match(/Ne/)
    rendered.should match(/12/)
    rendered.should match(/13/)
    rendered.should match(/14/)
  end
end
