require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:template) { FactoryBot.build(:valid_template) }

  specify 'valid_template is valid' do
    expect(template.valid?).to be_truthy
  end

  specify 'is not community permitted by default' do
    expect(Template.community_permitted?).to be_falsey
  end

  specify 'is_community can not be true when not permitted' do
    template.is_community = true
    template.valid?
    expect(template.errors.include?(:is_community)).to be_truthy
  end

  context 'when community is permitted' do
    before { allow(Template).to receive(:community_permitted?).and_return(true) }

    specify 'is_community? is true' do
      template.is_community = true
      expect(template.is_community?).to be_truthy
    end

    specify 'community template is saved without a project' do
      template.is_community = true
      template.save!
      expect(template.reload.project_id).to eq(nil)
    end

    specify 'project template becoming community loses its project' do
      template.save!
      template.update!(is_community: true)
      expect(template.reload.project_id).to eq(nil)
    end

    specify 'community template becoming project gets the current project' do
      template.is_community = true
      template.save!
      template.update!(is_community: false)
      expect(template.reload.project_id).to eq(Current.project_id)
    end

    specify 'community templates are unique across projects' do
      FactoryBot.create(:valid_template, name: 'Label', is_community: true)
      t = FactoryBot.build(:valid_template, name: 'Label', is_community: true, project: FactoryBot.create(:valid_project))
      expect(t.valid?).to be_falsey
    end

    specify 'community and project template may share name' do
      FactoryBot.create(:valid_template, name: 'Label', is_community: true)
      expect(FactoryBot.build(:valid_template, name: 'Label').valid?).to be_truthy
    end
  end
end
