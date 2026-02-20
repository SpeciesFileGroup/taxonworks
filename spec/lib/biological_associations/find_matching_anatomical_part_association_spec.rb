require 'rails_helper'

RSpec.describe BiologicalAssociations::FindMatchingAnatomicalPartAssociation, type: :model do
  let(:relationship) { FactoryBot.create(:valid_biological_relationship) }
  let(:subject_otu) { FactoryBot.create(:valid_otu) }
  let(:related_otu) { FactoryBot.create(:valid_otu) }

  def find(params)
    described_class.new(params, project_id: subject_otu.project_id).find
  end

  def base_params(overrides = {})
    {
      biological_relationship_id: relationship.id,
      biological_association_subject_id: subject_otu.id,
      biological_association_subject_type: 'Otu',
      biological_association_object_id: related_otu.id,
      biological_association_object_type: 'Otu'
    }.merge(overrides)
  end

  describe '#find' do
    context 'when no AP attributes are present' do
      it 'returns nil' do
        expect(find(base_params)).to be_nil
      end
    end

    context 'subject AP by name' do
      let!(:existing_ap) do
        FactoryBot.create(:valid_anatomical_part, ancestor: subject_otu, name: 'wing', is_material: false)
      end

      let!(:existing_ba) do
        FactoryBot.create(:valid_biological_association,
          biological_relationship: relationship,
          biological_association_subject: existing_ap,
          biological_association_object: related_otu)
      end

      it 'finds the matching BA' do
        params = base_params(subject_anatomical_part_attributes: { name: 'wing' })
        expect(find(params)).to eq(existing_ba)
      end

      it 'returns nil when the name does not match' do
        params = base_params(subject_anatomical_part_attributes: { name: 'leg' })
        expect(find(params)).to be_nil
      end

      it 'returns nil when the origin does not match' do
        other_otu = FactoryBot.create(:valid_otu)
        params = base_params(
          biological_association_subject_id: other_otu.id,
          subject_anatomical_part_attributes: { name: 'wing' }
        )
        expect(find(params)).to be_nil
      end

      it 'returns the lowest id when multiple APs share the same identity and origin' do
        second_ap = FactoryBot.create(:valid_anatomical_part, ancestor: subject_otu, name: 'wing', is_material: false)
        second_ba = FactoryBot.create(:valid_biological_association,
          biological_relationship: relationship,
          biological_association_subject: second_ap,
          biological_association_object: related_otu)

        params = base_params(subject_anatomical_part_attributes: { name: 'wing' })
        expect(find(params).id).to eq([existing_ba.id, second_ba.id].min)
      end
    end

    context 'subject AP by URI' do
      let!(:existing_ap) do
        FactoryBot.create(:valid_anatomical_part,
          ancestor: subject_otu,
          name: nil,
          uri: 'http://purl.obolibrary.org/obo/UBERON_0000978',
          uri_label: 'leg',
          is_material: false)
      end

      let!(:existing_ba) do
        FactoryBot.create(:valid_biological_association,
          biological_relationship: relationship,
          biological_association_subject: existing_ap,
          biological_association_object: related_otu)
      end

      it 'finds the matching BA by URI and label' do
        params = base_params(subject_anatomical_part_attributes: {
          uri: 'http://purl.obolibrary.org/obo/UBERON_0000978',
          uri_label: 'leg'
        })
        expect(find(params)).to eq(existing_ba)
      end

      it 'returns nil when URI label does not match' do
        params = base_params(subject_anatomical_part_attributes: {
          uri: 'http://purl.obolibrary.org/obo/UBERON_0000978',
          uri_label: 'wrong label'
        })
        expect(find(params)).to be_nil
      end
    end

    context 'object AP by name' do
      let!(:related_ap) do
        FactoryBot.create(:valid_anatomical_part, ancestor: related_otu, name: 'head', is_material: false)
      end

      let!(:existing_ba) do
        FactoryBot.create(:valid_biological_association,
          biological_relationship: relationship,
          biological_association_subject: subject_otu,
          biological_association_object: related_ap)
      end

      it 'finds the matching BA' do
        params = base_params(object_anatomical_part_attributes: { name: 'head' })
        expect(find(params)).to eq(existing_ba)
      end
    end
  end

end
