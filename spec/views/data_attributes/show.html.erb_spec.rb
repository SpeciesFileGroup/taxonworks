require 'rails_helper'

describe "data_attributes/show", :type => :view do
  before(:each) do
    @data_attribute = assign(:data_attribute, stub_model(DataAttribute,
      :type => "Type",
      :attribute_subject_id => 1,
      :attribute_subject_type => "Attribute Subject Type",
      :controlled_vocabulary_term_id => 2,
      :import_predicate => "Import Predicate",
      :value => "MyText",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Attribute Subject Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Import Predicate/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
  end
end
