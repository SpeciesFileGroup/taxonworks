require 'rails_helper'

describe Queries::FieldOccurrence::Autocomplete, type: :model do

  context 'restrict_to' do
    let(:otu) { FactoryBot.create(:valid_otu, name: 'Zzyzxdetermined') }
    let!(:o1) { FactoryBot.create(:valid_field_occurrence) }
    let!(:o2) { FactoryBot.create(:valid_field_occurrence) }

    before do
      [o1, o2].each do |o|
        FactoryBot.create(:valid_taxon_determination, otu:, taxon_determination_object: o)
      end
    end

    specify 'restricts results to the given FieldOccurrences' do
      q = Queries::FieldOccurrence::Autocomplete.new('Zzyzxdetermined', project_id:, restrict_to: ::FieldOccurrence.where(id: o2.id))
      expect(q.autocomplete).to contain_exactly(o2)
    end

    specify 'restricts exact id matches' do
      q = Queries::FieldOccurrence::Autocomplete.new(o1.id.to_s, project_id:, restrict_to: ::FieldOccurrence.where(id: o2.id))
      expect(q.autocomplete).to_not include(o1)
    end

    specify 'raises when the relation is of another model' do
      q = Queries::FieldOccurrence::Autocomplete.new('Zzyzxdetermined', project_id:, restrict_to: Otu.all)
      expect { q.autocomplete }.to raise_error(ArgumentError, /Otu/)
    end

    specify 'is not applied when nil' do
      q = Queries::FieldOccurrence::Autocomplete.new('Zzyzxdetermined', project_id:, restrict_to: nil)
      expect(q.autocomplete).to include(o1, o2)
    end
  end

end
