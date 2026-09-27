require 'rails_helper'

describe Queries::AnatomicalPart::Autocomplete, type: :model do

  context 'restrict_to' do
    let!(:ap1) { FactoryBot.create(:valid_anatomical_part, name: 'Zzyzxpart') }
    let!(:ap2) { FactoryBot.create(:valid_anatomical_part, name: 'Zzyzxpart') }

    specify 'restricts results to the given AnatomicalParts' do
      q = Queries::AnatomicalPart::Autocomplete.new('Zzyzxpart', project_id:, restrict_to: ::AnatomicalPart.where(id: ap2.id))
      expect(q.autocomplete).to contain_exactly(ap2)
    end

    specify 'raises when the relation is of another model' do
      q = Queries::AnatomicalPart::Autocomplete.new('Zzyzxpart', project_id:, restrict_to: Otu.all)
      expect { q.autocomplete }.to raise_error(ArgumentError, /Otu/)
    end

    specify 'is not applied when nil' do
      q = Queries::AnatomicalPart::Autocomplete.new('Zzyzxpart', project_id:, restrict_to: nil)
      expect(q.autocomplete).to include(ap1, ap2)
    end

    specify 'without project_id' do
      q = Queries::AnatomicalPart::Autocomplete.new('Zzyzxpart', restrict_to: ::AnatomicalPart.where(id: ap2.id))
      expect(q.autocomplete).to contain_exactly(ap2)
    end
  end

end
