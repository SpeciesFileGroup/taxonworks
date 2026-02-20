require 'rails_helper'

RSpec.describe BiologicalAssociationsController, type: :controller do
  before(:each) do
    sign_in
  end

  let(:valid_session) { {} }
  let(:relationship) { FactoryBot.create(:valid_biological_relationship) }

  describe 'POST create' do
    it 'creates a biological association without anatomical parts' do
      subject_otu = FactoryBot.create(:valid_otu)
      object_otu = FactoryBot.create(:valid_otu)

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_otu.id,
              biological_association_subject_type: 'Otu',
              biological_association_object_id: object_otu.id,
              biological_association_object_type: 'Otu'
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'creates related taxon determination and anatomical part when requested' do
      subject_otu = FactoryBot.create(:valid_otu)
      related_specimen = FactoryBot.create(:valid_specimen)
      determination_otu = FactoryBot.create(:valid_otu)

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_otu.id,
              biological_association_subject_type: 'Otu',
              biological_association_object_id: related_specimen.id,
              biological_association_object_type: 'CollectionObject',
              object_taxon_determination_attributes: {
                otu_id: determination_otu.id
              },
              object_anatomical_part_attributes: {
                name: 'leg',
                is_material: true
              }
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(1)
        .and change(TaxonDetermination, :count).by(1)
        .and change(AnatomicalPart, :count).by(1)

      expect(response).to have_http_status(:created)

      association = BiologicalAssociation.last
      object = association.biological_association_object

      expect(object).to be_a(AnatomicalPart)
      expect(object.inbound_origin_relationship.old_object).to eq(related_specimen)
      expect(related_specimen.reload.taxon_determinations.count).to eq(1)
    end

    it 'creates subject taxon determination and anatomical part when CO subject has no TD' do
      subject_specimen = FactoryBot.create(:valid_specimen)
      object_otu = FactoryBot.create(:valid_otu)
      determination_otu = FactoryBot.create(:valid_otu)

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_specimen.id,
              biological_association_subject_type: 'CollectionObject',
              biological_association_object_id: object_otu.id,
              biological_association_object_type: 'Otu',
              subject_taxon_determination_attributes: {
                otu_id: determination_otu.id
              },
              subject_anatomical_part_attributes: {
                name: 'wing',
                is_material: true
              }
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(1)
        .and change(TaxonDetermination, :count).by(1)
        .and change(AnatomicalPart, :count).by(1)

      expect(response).to have_http_status(:created)

      association = BiologicalAssociation.last
      subject = association.biological_association_subject

      expect(subject).to be_a(AnatomicalPart)
      expect(subject.inbound_origin_relationship.old_object).to eq(subject_specimen)
      expect(subject_specimen.reload.taxon_determinations.count).to eq(1)
    end

    it 'returns unprocessable content when subject part creation has no TD on CO' do
      subject_specimen = FactoryBot.create(:valid_specimen)
      object_otu = FactoryBot.create(:valid_otu)

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_specimen.id,
              biological_association_subject_type: 'CollectionObject',
              biological_association_object_id: object_otu.id,
              biological_association_object_type: 'Otu',
              subject_anatomical_part_attributes: {
                name: 'wing',
                is_material: true
              }
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(0)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns unprocessable content when related part creation has no TD path' do
      subject_otu = FactoryBot.create(:valid_otu)
      related_specimen = FactoryBot.create(:valid_specimen)

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_otu.id,
              biological_association_subject_type: 'Otu',
              biological_association_object_id: related_specimen.id,
              biological_association_object_type: 'CollectionObject',
              object_anatomical_part_attributes: {
                name: 'leg',
                is_material: true
              }
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(0)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'deduplicates create when subject anatomical part identity matches existing BA' do
      subject_otu = FactoryBot.create(:valid_otu)
      related_otu = FactoryBot.create(:valid_otu)

      existing_ap = FactoryBot.create(
        :valid_anatomical_part,
        ancestor: subject_otu,
        name: 'leg',
        is_material: false
      )

      existing_ba = FactoryBot.create(
        :valid_biological_association,
        biological_relationship: relationship,
        biological_association_subject: existing_ap,
        biological_association_object: related_otu
      )

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_otu.id,
              biological_association_subject_type: 'Otu',
              subject_anatomical_part_attributes: {
                name: 'leg'
              },
              biological_association_object_id: related_otu.id,
              biological_association_object_type: 'Otu'
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(0)
        .and change(AnatomicalPart, :count).by(0)

      expect(response).to have_http_status(:ok)
      expect(assigns(:biological_association).id).to eq(existing_ba.id)
    end

    it 'deduplicates to lowest id when multiple anatomical part matches exist' do
      subject_otu = FactoryBot.create(:valid_otu)
      related_otu = FactoryBot.create(:valid_otu)

      first_ap = FactoryBot.create(
        :valid_anatomical_part,
        ancestor: subject_otu,
        name: 'leg',
        is_material: false
      )
      second_ap = FactoryBot.create(
        :valid_anatomical_part,
        ancestor: subject_otu,
        name: 'leg',
        is_material: false
      )

      first_ba = FactoryBot.create(
        :valid_biological_association,
        biological_relationship: relationship,
        biological_association_subject: first_ap,
        biological_association_object: related_otu
      )
      FactoryBot.create(
        :valid_biological_association,
        biological_relationship: relationship,
        biological_association_subject: second_ap,
        biological_association_object: related_otu
      )

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_otu.id,
              biological_association_subject_type: 'Otu',
              subject_anatomical_part_attributes: {
                name: 'leg'
              },
              biological_association_object_id: related_otu.id,
              biological_association_object_type: 'Otu'
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(0)
        .and change(AnatomicalPart, :count).by(0)

      expect(response).to have_http_status(:ok)
      expect(assigns(:biological_association).id).to eq(first_ba.id)
    end

    it 'deduplicates create when related anatomical part identity matches existing BA' do
      subject_otu = FactoryBot.create(:valid_otu)
      related_otu = FactoryBot.create(:valid_otu)

      related_ap = FactoryBot.create(
        :valid_anatomical_part,
        ancestor: related_otu,
        name: 'head',
        is_material: false
      )

      existing_ba = FactoryBot.create(
        :valid_biological_association,
        biological_relationship: relationship,
        biological_association_subject: subject_otu,
        biological_association_object: related_ap
      )

      expect {
        post :create,
          params: {
            biological_association: {
              biological_relationship_id: relationship.id,
              biological_association_subject_id: subject_otu.id,
              biological_association_subject_type: 'Otu',
              biological_association_object_id: related_otu.id,
              biological_association_object_type: 'Otu',
              object_anatomical_part_attributes: {
                name: 'head'
              }
            }
          },
          session: valid_session,
          format: :json
      }.to change(BiologicalAssociation, :count).by(0)
        .and change(AnatomicalPart, :count).by(0)

      expect(response).to have_http_status(:ok)
      expect(assigns(:biological_association).id).to eq(existing_ba.id)
    end
  end
end
