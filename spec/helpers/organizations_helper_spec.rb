require 'rails_helper'

describe OrganizationsHelper, type: :helper do
  let(:organization) { FactoryBot.create(:valid_organization) }

  specify '#organization_tag' do
    expect(helper.organization_tag(organization)).to eq(organization.name)
  end

  specify '#organization_link' do
    expect(helper.organization_link(organization)).to have_link(organization.name)
  end

  specify '#organizations_search_form' do
    expect(helper.organizations_search_form).to have_field('organization_id_for_quick_search_form')
  end
end
