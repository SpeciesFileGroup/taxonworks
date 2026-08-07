require 'rails_helper'

describe AnatomicalPartsHelper, type: :helper do

  context 'tripwires for assumptions in anatomical_part_tag and label_for_anatomical_part' do

    specify 'AnatomicalPart valid origin base classes are the expected set' do
      base_classes = AnatomicalPart.valid_old_object_classes.map { |c| c.constantize.base_class.name }.uniq
      expect(base_classes).to contain_exactly('Otu', 'CollectionObject', 'AnatomicalPart', 'FieldOccurrence')
    end

    context 'label_for_collection_object does not include OTU/determination' do
      let(:otu) { FactoryBot.create(:valid_otu, name: 'TRIPWIRE_OTU_NAME') }
      let(:specimen) { FactoryBot.create(:valid_specimen) }

      before { FactoryBot.create(:valid_taxon_determination, otu:, taxon_determination_object: specimen) }

      specify 'otu name is absent from label' do
        expect(helper.label_for_collection_object(specimen)).not_to include('TRIPWIRE_OTU_NAME')
      end
    end

    context 'label_for_field_occurrence does not include OTU/determination' do
      let(:otu) { FactoryBot.create(:valid_otu, name: 'TRIPWIRE_OTU_NAME') }
      let(:field_occurrence) { FactoryBot.create(:valid_field_occurrence) }

      before { FactoryBot.create(:valid_taxon_determination, otu:, taxon_determination_object: field_occurrence) }

      specify 'otu name is absent from label' do
        expect(helper.label_for_field_occurrence(field_occurrence)).not_to include('TRIPWIRE_OTU_NAME')
      end
    end

  end

end
