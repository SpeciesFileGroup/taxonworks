require 'rails_helper'

RSpec.describe FieldOccurrence, type: :model do

  let(:field_occurrence) { FieldOccurrence.new }
  let(:otu) { Otu.create(name: 'Sunny') }
  let(:ce) { FactoryBot.create(:valid_collecting_event) }

  specify '#requires_taxon_determination?' do
    expect( FieldOccurrence.new.requires_taxon_determination?).to eq(true)
  end

  specify '#collecting_event' do
    expect(
      FieldOccurrence.new(collecting_event_id: ce.id)
    ).to be_truthy
  end

  specify 'total zero when absent' do
    field_occurrence.is_absent = true
    field_occurrence.valid?
    expect(field_occurrence.errors.messages).to include(:total)
  end

  context 'a taxon_determination is required' do
    before do
      field_occurrence.total = 1
      field_occurrence.collecting_event = FactoryBot.create(:valid_collecting_event)
    end

    specify 'absence of #otu, #origin_taxon_determination, #taxon_determinations invalidates' do
      expect(field_occurrence.valid?).to be_falsey
      expect(field_occurrence.errors.include?(:base)).to be_truthy
    end

    specify 'providing #taxon_determination validates' do
      field_occurrence.otu = FactoryBot.create(:valid_otu)
      expect(field_occurrence.save).to be_truthy
      expect(field_occurrence.taxon_determinations.count).to eq(1)
    end

    specify 'providing #origin_taxon_determination validates' do
      field_occurrence.taxon_determination = TaxonDetermination.new(otu:)
      expect(field_occurrence.save).to be_truthy
      expect(field_occurrence.taxon_determinations.count).to eq(1)
    end

    specify 'providing a taxon_determination with #taxon_determinations_attributes validates' do
      field_occurrence.taxon_determinations_attributes = [{otu:}]
      expect(field_occurrence.save).to be_truthy
      expect(field_occurrence.taxon_determinations.count).to eq(1)
    end

    specify 'providing a taxon_determination with #taxon_determinations.build validates' do
      field_occurrence.taxon_determinations.build(otu:)
      expect(field_occurrence.save).to be_truthy
      expect(field_occurrence.taxon_determinations.count).to eq(1)
    end

    specify 'providing a taxon_determination with #taxon_determinations <<  validates' do
      field_occurrence.taxon_determinations << TaxonDetermination.new(otu:)
      expect(field_occurrence.save).to be_truthy
      expect(field_occurrence.taxon_determinations.count).to eq(1)
    end

    specify 'all attributes with #new validates' do
      a = FieldOccurrence.new(
        total: 1,
        collecting_event: FactoryBot.create(:valid_collecting_event),

        taxon_determinations_attributes: [{otu_id: FactoryBot.create(:valid_otu).id}])
      expect(a.save).to be_truthy
      expect(a.taxon_determinations.count).to eq(1)
    end

    context 'attempting to delete last taxon_determination' do
      specify 'permitted when deleting self' do
        field_occurrence.taxon_determination = TaxonDetermination.new(otu:)
        field_occurrence.save!
        expect(field_occurrence.destroy).to be_truthy
        expect(FieldOccurrence.count).to be(0)
      end

      specify 'when taxon_determination is origin_ciation' do
        field_occurrence.otu = otu
        field_occurrence.save!
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        expect(field_occurrence.taxon_determinations.reload.first.destroy).to be_falsey
      end

      specify 'when taxon_determination is not origin taxon_determination' do
        field_occurrence.taxon_determinations <<  TaxonDetermination.new(otu:)
        expect(field_occurrence.save).to be_truthy
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        expect(field_occurrence.taxon_determinations.reload.first.destroy).to be_falsey
      end
    end
  end

end
