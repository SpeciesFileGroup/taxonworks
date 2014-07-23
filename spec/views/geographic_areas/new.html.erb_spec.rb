require 'rails_helper'

describe 'geographic_areas/new', :type => :view do
  before(:each) do
    assign(:geographic_area,
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
  end

  it 'renders new geographic_area form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form[action=?][method=?]', geographic_areas_path, 'post' do
      assert_select 'input#geographic_area_name[name=?]', 'geographic_area[name]'
      assert_select 'input#geographic_area_level0_id[name=?]', 'geographic_area[level0_id]'
      assert_select 'input#geographic_area_level1_id[name=?]', 'geographic_area[level1_id]'
      assert_select 'input#geographic_area_level2_id[name=?]', 'geographic_area[level2_id]'
      assert_select 'input#geographic_area_parent_id[name=?]', 'geographic_area[parent_id]'
      assert_select 'input#geographic_area_geographic_area_type_id[name=?]', 'geographic_area[geographic_area_type_id]'
      assert_select 'input#geographic_area_iso_3166_a2[name=?]', 'geographic_area[iso_3166_a2]'
      assert_select 'input#geographic_area_iso_3166_a3[name=?]', 'geographic_area[iso_3166_a3]'
    end
  end
end
