require 'rails_helper'

RSpec.describe ObservationMatrixRowItem::Dynamic::TaxonName, type: :model, group: :observation_matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem::Dynamic::TaxonName.new }

  context 'validation' do
    before { observation_matrix_row_item.valid? }


    context 'with a observation_matrix_row_item saved' do
      let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }

      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:t1) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
      let!(:t2) { Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: t1)  }
      let!(:t3) { Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, :subspecies), parent: t2)  }

      let!(:o1) { Otu.create!(taxon_name: t1) }

      before { observation_matrix_row_item.update!(
        observation_object: t1,
        observation_matrix:  observation_matrix)}

      specify '.observation_objects' do
        expect(observation_matrix_row_item.observation_objects).to contain_exactly(o1)
      end

      context 'adding an item synchronizes observation_matrix_rows' do
        specify 'saving a record adds otus observation_matrix_rows' do
          expect(ObservationMatrixRow.all.map(&:observation_object)).to contain_exactly(o1)
        end

        specify 'added observation_matrix_rows have reference_count == 1' do
          expect(ObservationMatrixRow.all.pluck(:reference_count)).to contain_exactly(1)
        end

        specify 'added observation_matrix_rows have cached_observation_matrix_row_item_id == nil' do
          expect(ObservationMatrixRow.all.pluck(:cached_observation_matrix_row_item_id)).to contain_exactly(nil)
        end

        specify 'destroying a record removes otus and collection objects from observation_matrix_rows' do
          observation_matrix_row_item.destroy
          expect(ObservationMatrixRow.count).to eq 0
        end

        context 'added in multiple matrices' do
          let!(:om1) { FactoryBot.create(:valid_observation_matrix, name: 'something different') }
          let!(:omri) { ObservationMatrixRowItem::Dynamic::TaxonName.create!(observation_object: t1, observation_matrix: om1) }

          specify 'saving a record adds observation_matrix_rows' do
            expect(ObservationMatrixRow.all.map(&:observation_object)).to contain_exactly(o1, o1)
          end

          specify 'updating an OTU to be out of scope removes from matrix' do
            o1.update!(name: 'new name', taxon_name_id: nil)
            expect(ObservationMatrixRow.all.map(&:otu)).to contain_exactly()
          end

          # This is not required because taxon names can not be
          # destroyed when linked to OTUs
          # specify 'destroying mri object updated multiple matrices - 1' do
          #   t1.destroy!
          #   expect(ObservationMatrixRow.all.size).to eq(0)
          # end

        end
      end

      context 'overlapping single item' do
        let!(:other_observation_matrix_row_item) { ObservationMatrixRowItem::Single.create!(observation_matrix: observation_matrix, observation_object: o1) }
        let(:observation_matrix_row) { ObservationMatrixRow.where(observation_matrix: observation_matrix, observation_object: o1).first}

        specify 'count is incremented' do
          expect(observation_matrix_row.reference_count).to eq(2)
        end

        specify 'cached_observation_matrix_row_item_id is returned' do
          expect(observation_matrix_row.cached_observation_matrix_row_item_id).to eq(other_observation_matrix_row_item.id)
        end

        context 'overlap (tag) is removed' do
          before { observation_matrix_row_item.destroy! }

          specify 'count is decremented' do
            expect(observation_matrix_row.reference_count).to eq(1)
          end

          specify 'cached_observation_matrix_row_item_id remains' do
            expect(observation_matrix_row.cached_observation_matrix_row_item_id).to eq(other_observation_matrix_row_item.id)
          end
        end
      end

    end
  end
end
