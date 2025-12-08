require 'rails_helper'

describe Utilities::Rails::Transmute, type: :model do
  describe '.move_associations' do
    context 'has_one associations' do
      specify 'moves origin_citation' do
        collection_object = FactoryBot.create(:valid_collection_object,
          origin_citation_attributes: { source: FactoryBot.create(:valid_source) })
        field_occurrence = FactoryBot.create(:valid_field_occurrence)
        origin_citation = collection_object.origin_citation

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(field_occurrence.reload.origin_citation).to eq(origin_citation)
        expect(origin_citation.reload.citation_object).to eq(field_occurrence)
      end
    end

    context 'has_many associations' do
      specify 'moves notes' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        note1 = FactoryBot.create(:valid_note, note_object: collection_object)
        note2 = FactoryBot.create(:valid_note, text: 'Second note', note_object: collection_object)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(note1.reload.note_object).to eq(field_occurrence)
        expect(note2.reload.note_object).to eq(field_occurrence)
        expect(field_occurrence.reload.notes.count).to eq(2)
        expect(collection_object.reload.notes.count).to eq(0)
      end

      specify 'moves citations' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        citation1 = FactoryBot.create(:valid_citation,
          citation_object: collection_object,
          source: FactoryBot.create(:valid_source))
        citation2 = FactoryBot.create(:valid_citation,
          citation_object: collection_object,
          source: FactoryBot.create(:valid_source))

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(citation1.reload.citation_object).to eq(field_occurrence)
        expect(citation2.reload.citation_object).to eq(field_occurrence)
        expect(field_occurrence.reload.citations.count).to eq(2)
        expect(collection_object.reload.citations.count).to eq(0)
      end

      specify 'moves tags' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        tag = FactoryBot.create(:valid_tag, tag_object: collection_object)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(tag.reload.tag_object).to eq(field_occurrence)
        expect(field_occurrence.reload.tags.count).to eq(1)
      end

      specify 'moves global identifiers (UUID) and preserves UUID value' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        # Use a global UUID identifier which works with FieldOccurrence
        # (unlike catalog numbers which are CO-specific)
        identifier = Identifier::Global::Uuid.new(identifier_object: collection_object)
        identifier.is_generated = true
        identifier.save!
        uuid_value = identifier.identifier  # Capture UUID value before move

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        # The UUID identifier should be moved to FO
        expect(identifier.reload.identifier_object).to eq(field_occurrence)

        # IMPORTANT: UUID value must be preserved during transmutation
        # Using update_columns (not update!) prevents UUID regeneration
        expect(identifier.identifier).to eq(uuid_value)

        # FO should have the moved identifier
        expect(field_occurrence.reload.identifiers).to include(identifier)
      end

      specify 'does not move DWC Occurrence identifiers' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        # Get the CO's DWC occurrence identifier before move
        co_dwc_id = collection_object.identifiers.reload.find do |i|
          i.is_a?(Identifier::Global::Uuid::TaxonworksDwcOccurrence)
        end
        co_dwc_value = co_dwc_id&.identifier

        # Get the FO's DWC occurrence identifier before move
        fo_dwc_id = field_occurrence.identifiers.reload.find do |i|
          i.is_a?(Identifier::Global::Uuid::TaxonworksDwcOccurrence)
        end
        fo_dwc_value = fo_dwc_id&.identifier

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        # After move, FO should still have only its original DWC identifier
        fo_dwc_after = field_occurrence.reload.identifiers.find do |i|
          i.is_a?(Identifier::Global::Uuid::TaxonworksDwcOccurrence)
        end

        expect(fo_dwc_after).not_to be_nil
        expect(fo_dwc_after.identifier).to eq(fo_dwc_value)  # Same value as before
        expect(fo_dwc_after.identifier).not_to eq(co_dwc_value) if co_dwc_value  # Different from CO's
      end

      specify 'does not move dwc_occurrence (has_one)' do
        # Create objects with dwc_occurrence enabled
        collection_object = FactoryBot.create(:valid_collection_object, no_dwc_occurrence: false)
        field_occurrence = FactoryBot.create(:valid_field_occurrence, no_dwc_occurrence: false)

        # Get the has_one dwc_occurrence records before move
        co_dwc = collection_object.dwc_occurrence
        fo_dwc = field_occurrence.dwc_occurrence

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        # Each should still have their own dwc_occurrence
        expect(collection_object.reload.dwc_occurrence).to eq(co_dwc)
        expect(field_occurrence.reload.dwc_occurrence).to eq(fo_dwc)
        expect(co_dwc.reload.dwc_occurrence_object).to eq(collection_object)
        expect(fo_dwc.reload.dwc_occurrence_object).to eq(field_occurrence)
      end

      specify 'moves data_attributes' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        data_attribute = FactoryBot.create(:valid_data_attribute, attribute_subject: collection_object)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(data_attribute.reload.attribute_subject).to eq(field_occurrence)
        expect(field_occurrence.reload.data_attributes.count).to eq(1)
      end

      specify 'moves depictions (and images through)' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        depiction1 = FactoryBot.create(:valid_depiction, depiction_object: collection_object)
        depiction2 = FactoryBot.create(:valid_depiction, depiction_object: collection_object)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(depiction1.reload.depiction_object).to eq(field_occurrence)
        expect(depiction2.reload.depiction_object).to eq(field_occurrence)
        expect(field_occurrence.reload.depictions.count).to eq(2)
        expect(field_occurrence.images.count).to eq(2)
      end

      specify 'moves confidences' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        confidence = FactoryBot.create(:valid_confidence, confidence_object: collection_object)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(confidence.reload.confidence_object).to eq(field_occurrence)
        expect(field_occurrence.reload.confidences.count).to eq(1)
      end

      specify 'moves protocol_relationships' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        protocol_relationship = FactoryBot.create(:valid_protocol_relationship,
          protocol_relationship_object: collection_object)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        expect(protocol_relationship.reload.protocol_relationship_object).to eq(field_occurrence)
        expect(field_occurrence.reload.protocol_relationships.count).to eq(1)
      end
    end

    context 'skipped associations' do
      specify 'does not move belongs_to associations' do
        collection_object = FactoryBot.create(:valid_collection_object)
        ce1 = collection_object.collecting_event
        ce2 = FactoryBot.create(:valid_collecting_event)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)
        field_occurrence.update!(collecting_event: ce2)

        Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)

        # Field occurrence should keep its own collecting_event
        expect(field_occurrence.reload.collecting_event).to eq(ce2)
      end
    end

    context 'only moves shared associations' do
      specify 'does not move CO-specific associations' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        # Container is specific to CollectionObject (Shared::Containable)
        # FieldOccurrence doesn't include this concern

        # This should not raise an error even though FO doesn't have containers
        expect {
          Utilities::Rails::Transmute.move_associations(collection_object, field_occurrence)
        }.not_to raise_error
      end
    end
  end
end
