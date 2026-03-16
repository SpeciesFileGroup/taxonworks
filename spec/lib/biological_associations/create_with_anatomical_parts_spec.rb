require 'rails_helper'

RSpec.describe BiologicalAssociations::CreateWithAnatomicalParts, type: :model do
  let(:relationship) { FactoryBot.create(:valid_biological_relationship) }
  let(:subject_otu) { FactoryBot.create(:valid_otu) }
  let(:object_otu) { FactoryBot.create(:valid_otu) }
  let(:determination_otu) { FactoryBot.create(:valid_otu) }

  def call(params)
    service = described_class.new(params)
    [service, service.call]
  end

  def base_params(overrides = {})
    {
      biological_relationship_id: relationship.id,
      biological_association_subject_id: subject_otu.id,
      biological_association_subject_type: 'Otu',
      biological_association_object_id: object_otu.id,
      biological_association_object_type: 'Otu'
    }.merge(overrides)
  end

  context 'OTU subject and object, no anatomical parts' do
    specify 'creates the biological association' do
      expect {
        service, success = call(base_params)
        expect(success).to be true
      }.to change(BiologicalAssociation, :count).by(1)
    end

    specify 'sets subject and object correctly' do
      service, _ = call(base_params)
      biological_association = service.biological_association
      expect(biological_association.biological_association_subject).to eq(subject_otu)
      expect(biological_association.biological_association_object).to eq(object_otu)
    end
  end

  context 'subject anatomical part from OTU' do
    let(:params) do
      base_params(subject_anatomical_part_attributes: { name: 'wing', is_material: false })
    end

    specify 'creates the biological association, anatomical part, and sets anatomical part as subject' do
      expect { call(params) }
        .to change(BiologicalAssociation, :count).by(1)
        .and change(AnatomicalPart, :count).by(1)

      biological_association = BiologicalAssociation.last
      expect(biological_association.biological_association_subject).to be_a(AnatomicalPart)
      expect(biological_association.biological_association_subject.name).to eq('wing')
    end

    specify 'sets origin of the anatomical part to the subject OTU' do
      call(params)
      anatomical_part = AnatomicalPart.last
      expect(anatomical_part.inbound_origin_relationship.old_object).to eq(subject_otu)
    end

    specify 'defaults is_material to false for OTU origin' do
      call(params.except(:subject_anatomical_part_attributes).merge(
        subject_anatomical_part_attributes: { name: 'wing' }
      ))
      expect(AnatomicalPart.last.is_material).to be false
    end
  end

  context 'object anatomical part from OTU' do
    let(:params) do
      base_params(object_anatomical_part_attributes: { name: 'head', is_material: false })
    end

    specify 'creates the biological association and anatomical part and sets anatomical part as object' do
      expect { call(params) }
        .to change(BiologicalAssociation, :count).by(1)
        .and change(AnatomicalPart, :count).by(1)

      biological_association = BiologicalAssociation.last
      expect(biological_association.biological_association_object).to be_a(AnatomicalPart)
      expect(biological_association.biological_association_object.name).to eq('head')
    end
  end

  context 'subject anatomical part from CollectionObject with taxon determination' do
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let(:params) do
      {
        biological_relationship_id: relationship.id,
        biological_association_subject_id: specimen.id,
        biological_association_subject_type: 'CollectionObject',
        biological_association_object_id: object_otu.id,
        biological_association_object_type: 'Otu',
        subject_anatomical_part_attributes: { name: 'leg' },
        subject_taxon_determination_attributes: { otu_id: determination_otu.id }
      }
    end

    specify 'creates biological association, anatomical part, and taxon determination' do
      expect { call(params) }
        .to change(BiologicalAssociation, :count).by(1)
        .and change(AnatomicalPart, :count).by(1)
        .and change(TaxonDetermination, :count).by(1)
    end

    specify 'defaults is_material to true for CollectionObject origin' do
      call(params)
      expect(AnatomicalPart.last.is_material).to be true
    end

    specify 'does not create a second taxon determination if the collection object already has one' do
      FactoryBot.create(:valid_taxon_determination, taxon_determination_object: specimen)

      expect { call(params) }
        .to change(TaxonDetermination, :count).by(0)
        .and change(AnatomicalPart, :count).by(1)
    end
  end

  context 'both subject and object anatomical parts' do
    let(:object_specimen) { FactoryBot.create(:valid_specimen) }
    let(:params) do
      {
        biological_relationship_id: relationship.id,
        biological_association_subject_id: subject_otu.id,
        biological_association_subject_type: 'Otu',
        biological_association_object_id: object_specimen.id,
        biological_association_object_type: 'CollectionObject',
        subject_anatomical_part_attributes: { name: 'wing', is_material: false },
        object_anatomical_part_attributes: { name: 'leg' },
        object_taxon_determination_attributes: { otu_id: determination_otu.id }
      }
    end

    specify 'creates biological association and two anatomical parts' do
      expect { call(params) }
        .to change(BiologicalAssociation, :count).by(1)
        .and change(AnatomicalPart, :count).by(2)
    end
  end

  context 'invalid params' do
    specify 'returns false and populates errors when biological association is invalid' do
      service, success = call(base_params(biological_relationship_id: nil))
      expect(success).to be false
      expect(service.errors).not_to be_empty
    end

    specify 'rolls back anatomical part and taxon determination creation when biological association save fails' do
      # Force biological association to be invalid by omitting the relationship.
      params = base_params(
        biological_relationship_id: nil,
        subject_anatomical_part_attributes: { name: 'wing', is_material: false },
        subject_taxon_determination_attributes: { otu_id: determination_otu.id }
      )

      expect { call(params) }
        .to change(AnatomicalPart, :count).by(0)
        .and change(TaxonDetermination, :count).by(0)
    end
  end
end
