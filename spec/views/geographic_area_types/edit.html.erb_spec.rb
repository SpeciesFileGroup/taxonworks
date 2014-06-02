require 'spec_helper'

describe 'geographic_area_types/edit' do
  before(:each) do
    @geographic_area_type = assign(:geographic_area_type, stub_model(GeographicAreaType,
                                                                     :name          => 'StubAreaType',
                                                                     :created_by_id => 1,
                                                                     :updated_by_id => 1
    ))
  end

  it 'renders the edit geographic_area_type form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", geographic_area_type_path(@geographic_area_type), "post" do
      assert_select "input#geographic_area_type_name[name=?]", "geographic_area_type[name]"
      # assert_select "input#geographic_area_type_created_by_id[name=?]", "geographic_area_type[created_by_id]"
      # assert_select "input#geographic_area_type_updated_by_id[name=?]", "geographic_area_type[updated_by_id]"
    end
  end
end
