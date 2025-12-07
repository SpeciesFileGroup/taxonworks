require 'rails_helper'

describe Utilities::Transmute, type: :model do
  describe '.move_associations' do
    context 'has_one associations' do
      specify 'moves origin_citation' do
        collection_object = FactoryBot.create(:valid_collection_object,
          origin_citation_attributes: { source: FactoryBot.create(:valid_source) })
        field_occurrence = FactoryBot.create(:valid_field_occurrence)
        origin_citation = collection_object.origin_citation

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

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

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

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

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(citation1.reload.citation_object).to eq(field_occurrence)
        expect(citation2.reload.citation_object).to eq(field_occurrence)
        expect(field_occurrence.reload.citations.count).to eq(2)
        expect(collection_object.reload.citations.count).to eq(0)
      end

      specify 'moves tags' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        tag = FactoryBot.create(:valid_tag, tag_object: collection_object)

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(tag.reload.tag_object).to eq(field_occurrence)
        expect(field_occurrence.reload.tags.count).to eq(1)
      end

      specify 'moves identifiers' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        identifier = FactoryBot.create(:valid_identifier, identifier_object: collection_object)

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(identifier.reload.identifier_object).to eq(field_occurrence)
        expect(field_occurrence.reload.identifiers.count).to eq(1)
      end

      specify 'moves data_attributes' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        data_attribute = FactoryBot.create(:valid_data_attribute, attribute_subject: collection_object)

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(data_attribute.reload.attribute_subject).to eq(field_occurrence)
        expect(field_occurrence.reload.data_attributes.count).to eq(1)
      end

      specify 'moves depictions (and images through)' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        depiction1 = FactoryBot.create(:valid_depiction, depiction_object: collection_object)
        depiction2 = FactoryBot.create(:valid_depiction, depiction_object: collection_object)

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(depiction1.reload.depiction_object).to eq(field_occurrence)
        expect(depiction2.reload.depiction_object).to eq(field_occurrence)
        expect(field_occurrence.reload.depictions.count).to eq(2)
        expect(field_occurrence.images.count).to eq(2)
      end

      specify 'moves confidences' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        confidence = FactoryBot.create(:valid_confidence, confidence_object: collection_object)

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(confidence.reload.confidence_object).to eq(field_occurrence)
        expect(field_occurrence.reload.confidences.count).to eq(1)
      end

      specify 'moves protocol_relationships' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        protocol_relationship = FactoryBot.create(:valid_protocol_relationship,
          protocol_relationship_object: collection_object)

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

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

        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        # Field occurrence should keep its own collecting_event
        expect(field_occurrence.reload.collecting_event).to eq(ce2)
      end

      specify 'does not move through associations directly' do
        collection_object = FactoryBot.create(:valid_collection_object)
        field_occurrence = FactoryBot.create(:valid_field_occurrence)

        # Images are accessed through depictions (a through association)
        depiction = FactoryBot.create(:valid_depiction, depiction_object: collection_object)

        # The depiction should move, making images available through it
        Utilities::Transmute.move_associations(collection_object, field_occurrence)

        expect(field_occurrence.reload.images.count).to eq(1)
        expect(field_occurrence.depictions.count).to eq(1)
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
          Utilities::Transmute.move_associations(collection_object, field_occurrence)
        }.not_to raise_error
      end
    end
  end
end
