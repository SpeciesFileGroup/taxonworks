require 'rails_helper'

describe ProjectsSources, :type => :model do

  let(:project_source) { FactoryGirl.build(:projects_source) }

  context 'validation' do
    before(:each) {
      project_source.valid?
    }
    context 'requires' do
      specify 'project' do
        expect(project_source.errors.include?(:project)).to be_truthy
      end
      specify 'project' do
        expect(project_source.errors.include?(:source)).to be_truthy
      end
    end
  end

end
