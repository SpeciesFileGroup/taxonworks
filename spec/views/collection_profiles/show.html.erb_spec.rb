require 'rails_helper'

describe "collection_profiles/show", :type => :view do
  before(:each) do
    @collection_profile = assign(:collection_profile, stub_model(CollectionProfile,
      :container_id => 1,
      :otu_id => 2,
      :conservation_status => 3,
      :processing_state => 4,
      :container_condition => 5,
      :condition_of_labels => 6,
      :identification_level => 7,
      :arrangement_level => 8,
      :data_quality => 9,
      :computerization_level => 10,
      :number_of_collection_objects => 11,
      :number_of_containers => 12,
      :created_by_id => 13,
      :updated_by_id => 14,
      :project_id => 15,
      :collection_type => "Collection Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/8/)
    expect(rendered).to match(/9/)
    expect(rendered).to match(/10/)
    expect(rendered).to match(/11/)
    expect(rendered).to match(/12/)
    expect(rendered).to match(/13/)
    expect(rendered).to match(/14/)
    expect(rendered).to match(/15/)
    expect(rendered).to match(/Collection Type/)
  end
end
