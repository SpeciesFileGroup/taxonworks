require 'rails_helper'

describe "otus/index", :type => :view do
  before(:each) do
    @data_model = Otu
    assign(:recent_objects, [
      stub_model(Otu,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3,
        :created_at => Time.now,
        :updated_at => Time.now,
      ),
      stub_model(Otu,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3,
        :created_at => Time.now,
        :updated_at => Time.now
      )
    ])
  end

  it "renders a list of otus" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    skip 'reconstruction of the otus/index view or spec'
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
