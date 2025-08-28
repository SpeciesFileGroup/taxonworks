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

     specify 'taxon_determinations count works after save through otu' do
        field_occurrence.otu = FactoryBot.create(:valid_otu)
        field_occurrence.save!

        # If we load/iterate the taxon_determinations association during FO
        # validation after assignment through otu, the association is empty
        # because the TD the otu determines hasn't been created yet, and then
        # taxon_determinations stays empty until we reload/reset the
        # association. Check that we're handling that.
        expect(field_occurrence.taxon_determinations.first.otu.id).to eq(field_occurrence.otu.id)
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

    context 'record associations after validation work' do
      specify 'taxon_determination associations work after save through otu' do
        field_occurrence.otu = otu
        field_occurrence.save!

        # With our associations, saving .otu automatically creates
        # taxon_determination and taxon_determinations.first.
        expect(field_occurrence.taxon_determinations.first.otu.id).to be_truthy
        expect(field_occurrence.taxon_determination.otu.id).to be_truthy
        expect(field_occurrence.otu.id).to be_truthy
      end

      specify 'taxon_determination associations work after save through taxon_determination' do
        field_occurrence.taxon_determination = TaxonDetermination.new(otu:)
        field_occurrence.save!

        # With our associations, saving .taxon_determination automatically
        # creates taxon_determinations.first, but *not* otu.
        expect(field_occurrence.taxon_determinations.first.otu.id).to be_truthy
        expect(field_occurrence.taxon_determination.otu.id).to be_truthy
      end

      specify 'taxon_determination associations work after save through taxon_determinations_attributes' do
        field_occurrence.taxon_determinations_attributes = [{otu:}]
        field_occurrence.save!

        expect(field_occurrence.taxon_determinations.first.otu.id).to be_truthy
      end
    end

    context 'attempting to delete last taxon_determination' do
      specify 'permitted when deleting self 1' do
        field_occurrence.taxon_determination = TaxonDetermination.new(otu:)
        field_occurrence.save!
        expect(field_occurrence.destroy).to be_truthy
        expect(FieldOccurrence.count).to be(0)
      end

      specify 'permitted when deleting self 2' do
        field_occurrence.taxon_determinations << TaxonDetermination.new(otu:)
        field_occurrence.save!
        expect(field_occurrence.destroy).to be_truthy
        expect(FieldOccurrence.count).to be(0)
      end

      specify 'when taxon_determination is through otu; destroy' do
        field_occurrence.otu = otu
        field_occurrence.save!
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        td.destroy
        expect(td.errors[:base].first).to match('taxon determination is required')
      end

      specify 'when taxon_determination is through otu; destroy!' do
        field_occurrence.otu = otu
        field_occurrence.save!
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        expect{ td.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(td.errors[:base].first).to match('taxon determination is required')
      end

      specify 'when taxon_determination is via <<; destroy' do
        field_occurrence.taxon_determinations <<  TaxonDetermination.new(otu:)
        expect(field_occurrence.save).to be_truthy
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        td.destroy
        expect(td.errors[:base].first).to match('taxon determination is required')
      end

      specify 'when taxon_determination is via <<; destroy!' do
        field_occurrence.taxon_determinations <<  TaxonDetermination.new(otu:)
        expect(field_occurrence.save).to be_truthy
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        expect{ td.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(td.errors[:base].first).to match('taxon determination is required')
      end

      context 'with _delete / marked_for_destruction' do
        context 'with !' do
          specify 'via a nested attribute delete' do
            field_occurrence.taxon_determinations << TaxonDetermination.new(otu:)
            field_occurrence.save!
            expect(field_occurrence.taxon_determinations.count).to eq(1)
            expect{field_occurrence.update!(taxon_determinations_attributes: {
              _destroy: true, id: field_occurrence.taxon_determinations.first.id
            })}.to raise_error(ActiveRecord::RecordInvalid, /taxon determination/)
          end

          specify 'trying to save field_occurrence with marked_for_destruction taxon_determinations' do
            field_occurrence.taxon_determinations << TaxonDetermination.new(otu:)
            field_occurrence.taxon_determinations.first.mark_for_destruction

            expect{field_occurrence.save!}
              .to raise_error(ActiveRecord::RecordInvalid, /taxon determination/)
          end

          specify 'trying to save field_occurrence with marked_for_destruction taxon_determination' do
            field_occurrence.taxon_determination = TaxonDetermination.new(otu:)
            field_occurrence.taxon_determination.mark_for_destruction

            expect{field_occurrence.save!}
              .to raise_error(ActiveRecord::RecordInvalid, /taxon determination/)
          end
        end

        context 'without !' do
          specify 'via a nested attribute delete' do
            field_occurrence.taxon_determinations << TaxonDetermination.new(otu:)
            field_occurrence.save!
            expect(field_occurrence.taxon_determinations.count).to eq(1)
            field_occurrence.update(taxon_determinations_attributes: {
              _destroy: true, id: field_occurrence.taxon_determinations.first.id
            })
            expect(field_occurrence.errors[:base].first).to match('taxon determination is not provided')
          end

          specify 'trying to save field_occurrence with marked_for_destruction taxon_determinations' do
            field_occurrence.taxon_determinations << TaxonDetermination.new(otu:)
            field_occurrence.taxon_determinations.first.mark_for_destruction

            field_occurrence.save
            expect(field_occurrence.errors[:base].first).to match('taxon determination is not provided')
          end

          specify 'trying to save field_occurrence with marked_for_destruction taxon_determination' do
            field_occurrence.taxon_determination = TaxonDetermination.new(otu:)
            field_occurrence.taxon_determination.mark_for_destruction

            field_occurrence.save
            expect(field_occurrence.errors[:base].first).to match('taxon determination is not provided')
          end
        end
      end
    end
  end

end
