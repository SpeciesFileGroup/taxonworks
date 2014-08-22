require 'rails_helper'

describe 'otus/show', :type => :view do
  before(:each) do
    @otu = assign(:otu,
                  stub_model(Otu,
                             :name          => 'Name',
                             :created_at    => Time.now - 1.week,
                             :updated_at    => Time.now - 6.days,
                             :created_by_id => 1,
                             :updated_by_id => 2,
                             :project_id    => 3
                  ))
  end

  it 'renders attributes in <p>' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
