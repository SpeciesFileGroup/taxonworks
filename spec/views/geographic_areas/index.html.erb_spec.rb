require 'rails_helper'

describe 'geographic_areas/index', :type => :view do
  before(:each) do
    assign(:geographic_areas, [
      stub_model(GeographicArea,
                 :name                    => 'Earth',
                 :parent_id               => 0,
                 :geographic_area_type_id => 2,
                 :iso_3166_a2             => 'AA',
                 :iso_3166_a3             => 'AAA',
                 :data_origin             => 'Someplace',
                 :tdwgID                  => '12CDE',
                 :level0_id               => 1,
                 :level1_id               => nil,
                 :level2_id               => nil,
                 :created_by_id           => 12,
                 :updated_by_id           => 13
      ),
      stub_model(GeographicArea,
                 :name                    => 'Name_1',
                 :parent_id               => 1,
                 :geographic_area_type_id => 2,
                 :iso_3166_a2             => 'AA',
                 :iso_3166_a3             => 'AAA',
                 :data_origin             => 'Someplace',
                 :tdwgID                  => '12CDE',
                 :level0_id               => 1,
                 :level1_id               => 1,
                 :level2_id               => 1,
                 :created_by_id           => 12,
                 :updated_by_id           => 13
      )
    ])
  end

  it 'renders a list of geographic_areas' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'tr>td', :text => 'Earth'.to_s, :count => 1
    assert_select 'tr>td', :text => 'Name_1'.to_s, :count => 1
    # skip 'reconstruction of the geographic_area/index view or spec'
    # assert_select 'tr>td', :text => 'Planet', :count => 2
    # assert_select 'tr>td', :text => 2.to_s, :count => 2
    assert_select 'tr>td', :text => 'AA'.to_s, :count => 2
    assert_select 'tr>td', :text => 'AAA'.to_s, :count => 2
    assert_select 'tr>td', :text => 'Someplace'.to_s, :count => 2
    assert_select 'tr>td', :text => '12CDE'.to_s, :count => 2
    assert_select 'tr>td', :text => 0.to_s, :count => 2
    # assert_select 'tr>td', :text => 4.to_s, :count => 2
    # assert_select 'tr>td', :text => 5.to_s, :count => 2
    assert_select 'tr>td', :text => 12.to_s, :count => 2
    assert_select 'tr>td', :text => 13.to_s, :count => 2
  end
end
