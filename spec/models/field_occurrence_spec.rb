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

  specify 'rejects non-zero total with ranged_lot_category' do
    category = FactoryBot.create(:valid_ranged_lot_category)
    field_occurrence.ranged_lot_category = category
    field_occurrence.total = 5
    field_occurrence.collecting_event = ce
    field_occurrence.otu = otu
    field_occurrence.valid?
    expect(field_occurrence.errors.messages).to include(:ranged_lot_category_id)
  end

  specify 'allows total: 0 with ranged_lot_category' do
    category = FactoryBot.create(:valid_ranged_lot_category)
    field_occurrence.ranged_lot_category = category
    field_occurrence.total = 0
    field_occurrence.collecting_event = ce
    field_occurrence.otu = otu
    expect(field_occurrence.valid?).to be_truthy
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
        expect(field_occurrence.taxon_determinations.count).to eq(1)
      end

      specify 'when taxon_determination is through otu; destroy!' do
        field_occurrence.otu = otu
        field_occurrence.save!
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        expect{ td.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(td.errors[:base].first).to match('taxon determination is required')
        expect(field_occurrence.taxon_determinations.count).to eq(1)
      end

      specify 'when taxon_determination is via <<; destroy' do
        field_occurrence.taxon_determinations <<  TaxonDetermination.new(otu:)
        expect(field_occurrence.save).to be_truthy
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        td.destroy
        expect(td.errors[:base].first).to match('taxon determination is required')
        expect(field_occurrence.taxon_determinations.count).to eq(1)
      end

      specify 'when taxon_determination is via <<; destroy!' do
        field_occurrence.taxon_determinations <<  TaxonDetermination.new(otu:)
        expect(field_occurrence.save).to be_truthy
        expect(field_occurrence.taxon_determinations.count).to eq(1)
        td = field_occurrence.taxon_determinations.reload.first
        expect{ td.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(td.errors[:base].first).to match('taxon determination is required')
        expect(field_occurrence.taxon_determinations.count).to eq(1)
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
            expect(field_occurrence.taxon_determinations.count).to eq(1)
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
            expect(field_occurrence.taxon_determinations.count).to eq(1)
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

  describe '.transmute_collection_object' do
    let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }
    let(:otu) { FactoryBot.create(:valid_otu) }

    context 'with valid collection object' do
      specify 'creates field occurrence with basic attributes' do
        co = FactoryBot.create(:valid_collection_object,
          total: 5,
          collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        result = FieldOccurrence.transmute_collection_object(co.id)

        expect(result).to be_a(Integer)
        fo = FieldOccurrence.find(result)
        expect(fo.total).to eq(5)
        expect(fo.collecting_event).to eq(collecting_event)
      end

      specify 'moves taxon determinations' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        td1 = TaxonDetermination.create!(otu: otu, taxon_determination_object: co)
        td2 = TaxonDetermination.create!(otu: FactoryBot.create(:valid_otu), taxon_determination_object: co)

        result = FieldOccurrence.transmute_collection_object(co.id)

        fo = FieldOccurrence.find(result)
        expect(fo.taxon_determinations.count).to eq(2)
        expect(fo.taxon_determinations).to contain_exactly(td1, td2)
        expect { co.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      specify 'moves shared associations via Utilities::Rails::Transmute' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        # Create one sample association to verify integration
        note = FactoryBot.create(:valid_note, note_object: co)

        result = FieldOccurrence.transmute_collection_object(co.id)

        fo = FieldOccurrence.find(result)
        expect(fo.notes).to include(note)
      end

      specify 'destroys original collection object' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!
        co_id = co.id

        FieldOccurrence.transmute_collection_object(co_id)

        expect { CollectionObject.find(co_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      specify 'handles ranged lot category' do
        category = FactoryBot.create(:valid_ranged_lot_category)
        co = RangedLot.create!(
          ranged_lot_category: category,
          collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        result = FieldOccurrence.transmute_collection_object(co.id)

        fo = FieldOccurrence.find(result)
        expect(fo.ranged_lot_category).to eq(category)
        expect(fo.total).to eq(0)  # Must be 0 (not nil) due to NOT NULL constraint
      end
    end

    context 'validation failures' do
      specify 'fails when collection object not found' do
        result = FieldOccurrence.transmute_collection_object(999999)
        expect(result).to eq('Collection object not found')
      end

      specify 'fails when collecting event is missing' do
        co = FactoryBot.create(:valid_collection_object)
        co.update_column(:collecting_event_id, nil)

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to eq('Collection object must have a collecting event')
      end

      specify 'fails when taxon determinations are missing' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to eq('Collection object must have at least one taxon determination')
      end

      specify 'fails when CO has incompatible identifiers (catalog number)' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        # Create a catalog number (not allowed on FieldOccurrence)
        Identifier::Local::CatalogNumber.create!(
          identifier_object: co,
          namespace: FactoryBot.create(:valid_namespace),
          identifier: '12345'
        )

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to match(/Failed to move associations/)
        expect(CollectionObject.exists?(co.id)).to be_truthy # Transaction rolled back
      end

      specify 'fails when CO has incompatible identifiers (record number)' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        # Create a record number (not allowed on FieldOccurrence)
        Identifier::Local::RecordNumber.create!(
          identifier_object: co,
          namespace: FactoryBot.create(:valid_namespace),
          identifier: 'RN456'
        )

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to match(/Failed to move associations/)
        expect(CollectionObject.exists?(co.id)).to be_truthy # Transaction rolled back
      end

      specify 'fails when CO has loan items' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        FactoryBot.create(:valid_loan_item, loan_item_object: co)

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to eq('Collection object has loan items. Please remove or return loans before converting.')
      end

      specify 'fails when CO has repository' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.repository = FactoryBot.create(:valid_repository)
        co.save!

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to eq('Collection object has a repository assignment. Please remove repository before converting.')
      end

      specify 'fails when CO has type materials' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!

        FactoryBot.create(:valid_type_material, collection_object: co)

        result = FieldOccurrence.transmute_collection_object(co.id)
        expect(result).to eq('Collection object has type materials. Please remove type materials before converting.')
      end
    end

    context 'transaction rollback' do
      specify 'rolls back on failure' do
        co = FactoryBot.create(:valid_collection_object, collecting_event: collecting_event)
        co.taxon_determinations << TaxonDetermination.new(otu: otu)
        co.save!
        co_id = co.id

        # Force a validation error by stubbing save! to fail
        allow_any_instance_of(FieldOccurrence).to receive(:save!).and_raise(
          ActiveRecord::RecordInvalid.new(FieldOccurrence.new)
        )

        result = FieldOccurrence.transmute_collection_object(co_id)

        # Should return error message
        expect(result).to be_a(String)
        # Original collection object should still exist
        expect { CollectionObject.find(co_id) }.not_to raise_error
      end
    end
  end

end
