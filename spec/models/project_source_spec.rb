require 'rails_helper'

describe ProjectSource do

  let(:project_source) { FactoryGirl.build(:project_source) }

  context 'validation' do
    before(:each) {
      project_source.valid?
    }
    context 'requires' do
      specify 'project' do
        expect(project_source.errors.include?(:project)).to be_falsey # get's it from Housekeeping
      end
      specify 'source' do
        expect(project_source.errors.include?(:source)).to be_truthy
      end
    end
  end

  context 'validation' do
    specify 'source is unique per project' do
      s = FactoryGirl.create(:valid_source)
      a = ProjectSource.new(project_id: 1, source: s)
      b = ProjectSource.new(project_id: 1, source: s)
      expect(a.save).to be_truthy
      expect(b.valid?).to be(false)
      expect(b.errors.include?(:source_id)).to be(true)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
