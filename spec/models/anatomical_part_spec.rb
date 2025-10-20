require 'rails_helper'

RSpec.describe AnatomicalPart, type: :model do
  let!(:otu) { FactoryBot.create(:valid_otu) }
  let!(:origin) { FactoryBot.create(:valid_collection_object) }
  let!(:inbound_origin_relationship_attributes) {
    {
      old_object_id: origin.id,
      old_object_type: origin.class.base_class.name
    }
  }

  before(:each) {
    origin.taxon_determinations << FactoryBot.create(:valid_taxon_determination, otu_id: otu.id)
  }

  context 'validations' do
    specify 'inbound_origin_relationship is required for valid AnatomicalPart' do
      a = AnatomicalPart.new({name: 'a'})
      expect(a.valid?).to be_falsey
    end

    specify 'name is valid' do
      expect(
        AnatomicalPart.create!({name: 'a', inbound_origin_relationship_attributes:})
      ).to be_truthy
    end

    specify 'uri and uri_label is valid' do
      expect(
        AnatomicalPart.create!(inbound_origin_relationship_attributes:,
        uri: 'http://val.id', uri_label: 'as a purl')
      ).to be_truthy
    end

    specify 'name and uri is not valid' do
      expect{
        AnatomicalPart.create!(name: 'a', inbound_origin_relationship_attributes:,
        uri: 'http://val.id')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'name and uri_label is not valid' do
      expect{
        AnatomicalPart.create!(name: 'a', inbound_origin_relationship_attributes:,
        uri_label: 'as a purl')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'name and uri and uri_label is not valid' do
      expect{
        AnatomicalPart.create!(name: 'a', inbound_origin_relationship_attributes:,
        uri: 'http://val.id', uri_label: 'as a purl')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'uri alone is not valid' do
      expect{
        AnatomicalPart.create!(uri: 'http://alo.ne',
          inbound_origin_relationship_attributes:)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'uri_label alone is not valid' do
      expect {
        AnatomicalPart.create!(uri_label: 'a',
          inbound_origin_relationship_attributes:)
     }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'name or uri/label required' do
      expect {
        AnatomicalPart.create!(inbound_origin_relationship_attributes:)
     }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'invalid origin type is caught' do
      expect {
        AnatomicalPart.create!(
          inbound_origin_relationship_attributes: {
            old_object_id: FactoryBot.create(:valid_depiction).id,
            old_object_type: 'Depiction'
          },
          name: 'not again')
      }.to raise_error(ActiveRecord::InverseOfAssociationNotFoundError)
    end

    specify 'non-otu taxonomic_origin_object must have a taxon_determination' do
      origin = Specimen.create!
      expect {
        AnatomicalPart.create!(
          inbound_origin_relationship_attributes: { old_object: origin },
          name: 'no td'
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    specify 'otu taxonomic origin_object is accepted' do
      origin = Otu.create!(name: 'a')
      expect(
        AnatomicalPart.create!(
          inbound_origin_relationship_attributes: { old_object: origin },
          name: 'no td'
        )
      ).to be_truthy
    end
  end

  context 'ancestor chains' do
    context 'must not be broken' do
      specify 'origin_relationship with anatomical_part child cannot be deleted' do
        ap1 = AnatomicalPart.create!({name: 'middle', inbound_origin_relationship_attributes:})
        ap2 = AnatomicalPart.create!(name: 'descendant',
          inbound_origin_relationship_attributes: {
            old_object: ap1
          })
        expect{ ap1.related_origin_relationships.first.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      specify 'origin_relationship with not anatomical_part child *can* be deleted' do
        ap1 = AnatomicalPart.create!({name: 'top', inbound_origin_relationship_attributes:})
        or_rel = OriginRelationship.create!(old_object: ap1, new_object: FactoryBot.create(:valid_extract))
        expect{ or_rel.destroy! }.not_to raise_error
      end

      specify 'anatomical_part with descendant (anatomical_part) cannot be deleted' do
        ap1 = AnatomicalPart.create!({name: 'middle', inbound_origin_relationship_attributes:})
        ap2 = AnatomicalPart.create!(name: 'descendant',
          inbound_origin_relationship_attributes: {
            old_object: ap1
          })
        expect{ ap1.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      specify 'anatomical_part with descendant (extract) cannot be deleted' do
        ap1 = AnatomicalPart.create!({name: 'middle', inbound_origin_relationship_attributes:})
        OriginRelationship.create!(
          old_object: ap1,
          new_object: FactoryBot.create(:valid_extract)
        )
        expect{ ap1.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      specify 'allows deletion of terminal anatomical_part' do
        ap1 = AnatomicalPart.create!({name: 'top', inbound_origin_relationship_attributes:})
        expect{ ap1.destroy! }.not_to raise_exception
      end
    end

    specify 'exactly one previous origin for each anatomical part' do
      a = AnatomicalPart.create!(name: 'popular', inbound_origin_relationship_attributes:)

      fo = FactoryBot.create(:valid_field_occurrence)

      expect{
        OriginRelationship.create!(
          old_object: fo,
          new_object: a
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context 'taxonomic_origin_object' do
      specify 'can be CollectionObject' do
        ap = AnatomicalPart.create!({name: 'a', inbound_origin_relationship_attributes:})

        expect(ap.taxonomic_origin_object).to eq(origin)
      end

      specify 'can be FieldOccurrence' do
        root = FactoryBot.create(:valid_field_occurrence)

        c1 = AnatomicalPart.create!(
          name: 'c1',
          inbound_origin_relationship_attributes: {
            old_object_id: root.id,
            old_object_type: 'FieldOccurrence'
          }
        )

        expect(c1.taxonomic_origin_object).to eq(root)
      end

      specify 'can be OTU' do
        root = FactoryBot.create(:valid_otu)

        c1 = AnatomicalPart.create!(
          name: 'c1',
          inbound_origin_relationship_attributes: {
            old_object_id: root.id,
            old_object_type: 'Otu'
          }
        )

        expect(c1.taxonomic_origin_object).to eq(root)
      end

      specify 'length 2 chain' do
        root = otu

        c1 = AnatomicalPart.create!(
          name: 'c1',
          inbound_origin_relationship_attributes: {
            old_object_id: root.id,
            old_object_type: 'Otu'
          }
        )

        c2 = AnatomicalPart.create!(
          name: 'c2',
          inbound_origin_relationship_attributes: {
            old_object_id: c1.id,
            old_object_type: 'AnatomicalPart'
          }
        )

        expect(c2.taxonomic_origin_object).to eq(root)
      end
    end

    context 'cached_otu_id' do
      specify 'Otu' do
        root = otu

        c1 = AnatomicalPart.create!(
          name: 'c1',
          inbound_origin_relationship_attributes: {
            old_object_id: root.id,
            old_object_type: 'Otu'
          }
        )

        expect(c1.cached_otu_id).to eq(otu.id)
      end

      specify 'Specimen' do
        root = origin

        c1 = AnatomicalPart.create!(
          name: 'c1',
          inbound_origin_relationship_attributes:
        )

        expect(c1.cached_otu_id).to eq(origin.otu.id)
      end
    end
  end

  specify 'can create complex graphs' do
    root = origin

    # length 1 chain
    c11 = AnatomicalPart.create!(
      name: 'c11',
      inbound_origin_relationship_attributes: {
        old_object_id: root.id,
        old_object_type: 'Specimen'
      }
    )

    # length 2 chain
    c21 = AnatomicalPart.create!(
      name: 'c21',
      inbound_origin_relationship_attributes: {
        old_object_id: root.id,
        old_object_type: 'Specimen'
      }
    )

    c22 = AnatomicalPart.create!(
      name: 'c22',
      inbound_origin_relationship_attributes: {
        old_object_id: c21.id,
        old_object_type: 'AnatomicalPart'
      }
    )

    # bifurcating chain
    c31 = AnatomicalPart.create!(
      name: 'c31',
      inbound_origin_relationship_attributes: {
        old_object_id: root.id,
        old_object_type: 'Specimen'
      }
    )

    c32 = AnatomicalPart.create!(
      name: 'c32',
      inbound_origin_relationship_attributes: {
        old_object_id: c31.id,
        old_object_type: 'AnatomicalPart'
      }
    )

    c331 = AnatomicalPart.create!(
      name: 'c331',
      inbound_origin_relationship_attributes: {
        old_object_id: c32.id,
        old_object_type: 'AnatomicalPart'
      }
    )

    c332 = AnatomicalPart.create!(
      name: 'c332',
      inbound_origin_relationship_attributes: {
        old_object_id: c32.id,
        old_object_type: 'AnatomicalPart'
      }
    )
  end

end
