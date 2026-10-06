require 'rails_helper'

describe ProjectOrganization, type: :model do

  let(:project_organization) { ProjectOrganization.new }

  context 'validation' do
    before(:each) { project_organization.valid? }

    specify 'requires organization' do
      expect(project_organization.errors.include?(:organization)).to be_truthy
    end

    specify 'project is set from Current' do
      expect(project_organization.errors.include?(:project)).to be_falsey
    end

    specify 'organization is unique per project' do
      o = FactoryBot.create(:valid_organization)
      a = ProjectOrganization.create!(organization: o)
      b = ProjectOrganization.new(organization: o)
      expect(b.valid?).to be(false)
      expect(b.errors.include?(:organization_id)).to be(true)
    end

    specify 'the same organization may be used in another project' do
      o = FactoryBot.create(:valid_organization)
      ProjectOrganization.create!(organization: o)
      b = ProjectOrganization.new(organization: o, project: FactoryBot.create(:valid_project))
      expect(b.valid?).to be(true)
    end
  end

  context 'associations' do
    let!(:project_organization) { FactoryBot.create(:valid_project_organization) }

    specify 'Project#organizations' do
      expect(project_organization.project.organizations).to include(project_organization.organization)
    end

    specify 'Organization#projects' do
      expect(project_organization.organization.projects).to include(project_organization.project)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
