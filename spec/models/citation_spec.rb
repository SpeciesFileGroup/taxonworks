require 'rails_helper'

describe Citation, :type => :model do
  let(:citation) { FactoryGirl.build(:citation) }

  context 'associations' do
    context 'belongs_to' do
      specify 'citation_object' do
        expect(citation).to respond_to(:citation_object)
      end

      specify 'source' do
        expect(citation).to respond_to(:source)
      end
    end
  end

  context 'validation' do
    let(:o) { FactoryGirl.create(:valid_otu) }
    let(:s) { FactoryGirl.create(:valid_source) }
    let(:c1) { FactoryGirl.create(:valid_citation, {citation_object: o, source: s}) }
    let(:c2) { FactoryGirl.build(:valid_citation, citation_object: o, source: s) }
    let(:c3) { FactoryGirl.build(:citation) }

    specify 'uniqueness' do
      expect(c1.valid?).to be_truthy
      expect(c2.valid?).to be_falsey
      expect(c2.errors.messages[:source_id][0]).to eq('has already been taken')
    end

    specify 'for all required fields (:citation_object_id, :citation_object_type, :source_id).' do
      expect(c3.valid?).to be_falsey
      messages = c3.errors.messages
      expect(messages[:citation_object_id][0]).to eq('can\'t be blank')
      expect(messages[:citation_object_type][0]).to eq('can\'t be blank')
      expect(messages[:source_id][0]).to eq('can\'t be blank')
    end

  end

end
