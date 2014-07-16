require 'rails_helper'

describe "public_contents/show" do
  before(:each) do
    @public_content = assign(:public_content, stub_model(PublicContent,
      :otu_id => 1,
      :topic_id => 2,
      :text => "MyText",
      :project_id => 3,
      :created_by_id => 4,
      :updated_by_id => 5,
      :content_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/MyText/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end
