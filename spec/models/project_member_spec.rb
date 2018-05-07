require 'rails_helper'

describe ProjectMember, type: :model do

  let(:project_member) {FactoryBot.build(:project_member) }

  context 'associations' do
    context 'belongs_to' do
      specify 'user' do
        expect(project_member).to respond_to(:user)
      end

      specify 'project' do
        expect(project_member).to respond_to(:project)
      end
    end
  end

  context 'validation' do

    before(:each) do
      project_member.valid?
    end

    specify 'user' do
      expect(project_member.errors.include?(:project)).to be_truthy
    end

    specify 'project' do
      expect(project_member.errors.include?(:user)).to be_truthy
    end
  end

  context '#clipboard' do
    before { project_member.clipboard = {'1' => 'foo', '2' => 'bar', '5' => 'stuff'} }

    specify 'slots 1' do
      expect(project_member.clipboard['1']).to eq('foo')
    end

  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end

