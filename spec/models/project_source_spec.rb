require 'rails_helper'

describe ProjectSource do

  let(:project_source) { FactoryGirl.build(:project_source) }

  context 'validation' do
    before(:each) {
      project_source.valid?
    }
    context 'requires' do
      specify 'project' do
        expect(project_source.errors.include?(:project)).to be_truthy
      end
      specify 'source' do
        expect(project_source.errors.include?(:source)).to be_truthy
      end
      skip 'test uniqueness of combination'
    end
  end

end
