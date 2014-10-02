require 'rails_helper'

describe "people/show", :type => :view do
  before(:each) do
    @person = assign(:person, stub_model(Person,
      type:  "Person::Vetted",
      last_name:  "Last Name",
      first_name: "First Name",
      suffix: "Suffix",
      prefix: "Prefix",
      created_by_id: 1,
      updated_by_id: 1,
      updated_at: Time.now(),
      created_at: Time.now()
    ))
    allow(@person).to receive(:pinned?).with(nil).and_return(false)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Suffix/)
    expect(rendered).to match(/Prefix/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
