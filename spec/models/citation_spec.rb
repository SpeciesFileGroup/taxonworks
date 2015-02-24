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
    # let(:c1) { FactoryGirl.create(:valid_citation, {otu: o, source: s}) }
    # let(:c2) { FactoryGirl.build(:valid_citation, otu: o, source: s) }

    pending 'further development'
    specify 'uniqueness' do
      # expect(c1.valid?).to be_truthy
      # expect(c2.valid?).to be_falsey
      # expect(c2.errors).to include('duplicate')
    end
    pending ' for all required fields (:citation_object_id, :citation_object_type, :source_id).'
  end

end
