require 'rails_helper'

describe DwcOccurrence, type: :model, group: [:darwin_core] do

  # This now creates a dwc_occurrence by default
  let(:collection_object) { FactoryBot.create(:valid_specimen, no_dwc_occurrence: false) }
  let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }

  let(:dwc_occurrence) { DwcOccurrence.new }

  let(:source_human) { FactoryBot.create(:valid_source_human) }
  let(:source_bibtex) { FactoryBot.create(:valid_source_bibtex) }
  let(:asserted_distribution) { FactoryBot.create(:valid_asserted_distribution) }


specify 'extending predicates' do
    s1 = Specimen.create
    s2 = Specimen.create
    s3 = Specimen.create
    
    p1 = FactoryBot.create(:valid_predicate)
    p2 = FactoryBot.create(:valid_predicate)
    d1 = InternalAttribute.create!( attribute_subject: s1, predicate: p1, value: 1)
    d2 = InternalAttribute.create!( attribute_subject: s2, predicate: p1, value: 2)
    
    #   a = DwcOccurrence.collection_object_join
    #     .left_outer_join(collection_objects: [:data_attributes])
    #     .where(data_attributes: nil).
    #     .or.where(data_attributes:
    #     .select("controlled_vocabulary_terms.name")
    #     .group('dwc_occurrences.id, controlled_vocabulary_terms.id')
    
    b = Predicate.joins(:internal_attributes)
    .where(data_attributes: { data_attribute_object_type: ['CollectionObject']})
    .select(:id, :name)
    
    c = InternalAttribute.select('t.*').from("CROSSTAB ('#{b.to_sql}') as t (pid, pname)")
    
    byebug
    
    expect(true).to eq(false)
    
end



  specify '#dwc_occurrence_id post .set_dwc_occurrence' do
    s = Specimen.create!(no_dwc_occurrence: true)
    expect(s.dwc_occurrence_id).to eq(nil)
    s.set_dwc_occurrence
    expect(collection_object.dwc_occurrence_id).to eq(collection_object.identifiers.first.identifier)
  end

  specify '.by_collection_object_filter 1' do
    3.times { Specimen.create }
    f = ::Queries::CollectionObject::Filter.new(user_date_start: Time.now.to_date.to_s).all # Note the .all
    a = DwcOccurrence.by_collection_object_filter(
      filter_scope: f,
      project_id: Current.project_id
    )

    expect(a.first.basisOfRecord).to eq('PreservedSpecimen')
  end

  specify '.by_collection_object_filter 2' do
    Specimen.create(created_at: 2.days.ago, updated_at: 2.days.ago)
    3.times { Specimen.create }
    f = ::Queries::CollectionObject::Filter.new(user_date_start: Time.now.to_date.to_s).all
    a = DwcOccurrence.by_collection_object_filter(
      filter_scope: f,
      project_id: Current.project_id
    )

    expect(a.size).to eq(3)
  end

  specify 'collection_object filter merge' do
    a = Queries::CollectionObject::Filter.new(on_loan: 'true').all
    FactoryBot.create(:valid_loan_item, loan_item_object: collection_object)

    # A canary, shouldn't be present since not on loan
    c = FactoryBot.create(:valid_specimen, no_dwc_occurrence: false)

    b = DwcOccurrence.collection_objects_join.merge(a)
    expect(b.all.count).to eq(1)
  end

  specify '#dwc_occurrence_id' do
    dwc_occurrence.dwc_occurrence_object = collection_object
    expect(collection_object.dwc_occurrence_id).to eq(collection_object.identifiers.first.identifier)
  end

  specify 'occurrences get proxy uuids 1' do
    dwc_occurrence.dwc_occurrence_object = collection_object # saves the record
    expect(collection_object.identifiers.count).to eq(1)
  end

  specify 'occurrences get proxy uuids, but not new ones' do
    # This saves collection_object, which triggers both DwC indexing and creation of an identifier
    # a = Identifier::Global::Uuid.create!(identifier_object: collection_object, is_generated: true)

    collection_object.identifiers_attributes = [{type: 'Identifier::Global::Uuid', is_generated: true}]
    collection_object.save!
    a = collection_object.identifiers.first
    expect(Identifier.count).to eq(1)
    dwc_occurrence.dwc_occurrence_object = collection_object # saves the record
    expect(collection_object.identifiers.first.identifier).to eq(a.identifier)
  end

  context 'validation' do
    # specify '#basisOfRecord is required' do
    #   expect(dwc_occurrence.errors.include?(:basisOfRecord)).to be_truthy
    # end

    specify '#dwc_occurrence_object is required' do
      dwc_occurrence.valid?
      expect(dwc_occurrence.errors.include?(:dwc_occurrence_object)).to be_truthy
    end

    context 'the referenced TW' do
      let(:new_dwc_occurrence) { DwcOccurrence.new }

      context '#collection_object' do
        before do
          new_dwc_occurrence.dwc_occurrence_object = collection_object
          new_dwc_occurrence.valid?
        end

        specify 'occurs only once' do
          expect(new_dwc_occurrence.errors.include?(:dwc_occurrence_object_id)).to be_truthy
        end
      end
    end
  end

  context '#basisOfRecord, on validation ' do
    context 'when collection object is provided' do
      before do
        dwc_occurrence.dwc_occurrence_object = collection_object
        dwc_occurrence.valid?
      end

      specify 'is automatically set' do
        expect(dwc_occurrence.basisOfRecord).to eq('PreservedSpecimen')
      end
    end

    context 'when asserted distribution is provided' do
      before { dwc_occurrence.dwc_occurrence_object = asserted_distribution }

      context 'and source is person' do
        before do
          dwc_occurrence.dwc_occurrence_object.source = source_human
          dwc_occurrence.valid?
        end

        specify 'is set to "HumanObservation"' do
          expect(dwc_occurrence.basisOfRecord).to eq('HumanObservation')
        end
      end

      context 'and source is bibtex' do
        before do
          dwc_occurrence.dwc_occurrence_object.source = source_bibtex
          dwc_occurrence.valid?
        end

        specify 'is set to "Occurrence"' do
          expect(dwc_occurrence.basisOfRecord).to eq('Occurrence')
        end
      end
    end
  end

  specify '#is_stale? 1' do
    a = collection_object.get_dwc_occurrence
    expect(a.is_stale?).to be_falsey
  end

  specify '#is_stale? 2' do
    a = collection_object.get_dwc_occurrence
    a.update!(updated_at: 2.weeks.ago)
    collecting_event.update!(updated_at: 1.week.ago)
    expect(a.is_stale?).to be_truthy
  end

  specify '#is_stale? 3' do
    a = collection_object.get_dwc_occurrence
    a.update!(updated_at: 2.weeks.ago)

    b = TaxonDetermination.new(otu: FactoryBot.create(:valid_otu))
    collection_object.taxon_determinations << b

    expect(a.is_stale?).to be_truthy
  end

  # Can't test within a transaction.
  specify '.empty_fields' do
    expect(::DwcOccurrence.empty_fields).to contain_exactly() # Should be ::DwcOccurrence.column_names
  end

end
