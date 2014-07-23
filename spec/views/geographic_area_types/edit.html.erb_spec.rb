require 'rails_helper'

describe 'geographic_area_types/edit', :type => :view do
  before(:each) do
    @geographic_area_type = assign(:geographic_area_type,
                                   stub_model(GeographicAreaType,
                                              :name          => 'StubAreaType'
                                   ))
  end

  it 'renders the edit geographic_area_type form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", geographic_area_type_path(@geographic_area_type), "post" do
      assert_select "input#geographic_area_type_name[name=?]", "geographic_area_type[name]"
      # on the geographic_area_types/edit view, created_by and updated_by are no longer represented
      # assert_select "input#geographic_area_type_created_by_id[name=?]", "geographic_area_type[created_by_id]"
      # assert_select "input#geographic_area_type_updated_by_id[name=?]", "geographic_area_type[updated_by_id]"
    end
  end
end
