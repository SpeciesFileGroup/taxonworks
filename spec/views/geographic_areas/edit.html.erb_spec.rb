require 'spec_helper'

describe 'geographic_areas/edit' do
  before(:each) do
    @geographic_area = assign(:geographic_area,
                              stub_model(GeographicArea,
                                         :name                    => 'Name',
                                         :parent_id               => 1,
                                         :geographic_area_type_id => 1,
                                         :iso_3166_a2             => 'MyString',
                                         :iso_3166_a3             => 'MyString',
                                         :data_origin             => 'MyString',
                                         :tdwgID                  => 'MyString',
                                         :level0_id               => 1,
                                         :level1_id               => 1,
                                         :level2_id               => 1,
                                         :created_by_id           => 1,
                                         :updated_by_id           => 1
                              ))
  end
=begin
                 :name                 => 'Name',
                 :parent               => 'ParentName',
                 :geographic_area_type => 'Area',
                 :iso_3166_a2          => 'Iso 3166 A2',
                 :iso_3166_a3          => 'Iso 3166 A3',
                 :data_origin          => 'Data Origin',
                 :tdwgID               => 'Tdwg',
                 :level0               => 'Name_1',
                 :level1               => 'Name_2',
                 :level2               => 'Name_3',
                 :created_by_id        => 12,
                 :updated_by_id        => 13

=end

  it 'renders the edit geographic_area form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form[action=?][method=?]', geographic_area_path(@geographic_area), 'post' do
      assert_select 'input#geographic_area_name[name=?]', 'geographic_area[name]'
      assert_select 'input#geographic_area_parent_id[name=?]', 'geographic_area[parent_id]'
      assert_select 'input#geographic_area_geographic_area_type_id[name=?]', 'geographic_area[geographic_area_type_id]'
      assert_select 'input#geographic_area_iso_3166_a2[name=?]', 'geographic_area[iso_3166_a2]'
      assert_select 'input#geographic_area_iso_3166_a3[name=?]', 'geographic_area[iso_3166_a3]'
      assert_select 'input#geographic_area_data_origin[name=?]', 'geographic_area[data_origin]'
      assert_select 'input#geographic_area_level0_id[name=?]', 'geographic_area[level0_id]'
      assert_select 'input#geographic_area_level1_id[name=?]', 'geographic_area[level1_id]'
      assert_select 'input#geographic_area_level2_id[name=?]', 'geographic_area[level2_id]'
      assert_select 'input#geographic_area_created_by_id[name=?]', 'geographic_area[created_by_id]'
      assert_select 'input#geographic_area_updated_by_id[name=?]', 'geographic_area[updated_by_id]'
    end
  end
end
