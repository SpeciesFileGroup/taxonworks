require 'rails_helper'

describe "data_attributes/index" do
  before(:each) do
    assign(:data_attributes, [
      stub_model(DataAttribute,
        :type => "Type",
        :attribute_subject_id => 1,
        :attribute_subject_type => "Attribute Subject Type",
        :controlled_vocabulary_term_id => 2,
        :import_predicate => "Import Predicate",
        :value => "MyText",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      ),
      stub_model(DataAttribute,
        :type => "Type",
        :attribute_subject_id => 1,
        :attribute_subject_type => "Attribute Subject Type",
        :controlled_vocabulary_term_id => 2,
        :import_predicate => "Import Predicate",
        :value => "MyText",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      )
    ])
  end

  it "renders a list of data_attributes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Attribute Subject Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Import Predicate".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end
