require 'rails_helper'

RSpec.describe ObservationMatrixRowItem::Dynamic::TaxonName, type: :model, group: :observation_matrix do
  let(:observation_matrix_row_item) { ObservationMatrixRowItem::Dynamic::TaxonName.new }

  context 'validation' do
    before { observation_matrix_row_item.valid? }

    context 'association' do
      specify 'belongs_to taxon_name' do
        expect(observation_matrix_row_item.taxon_name = Protonym.new()).to be_truthy
      end
    end

    specify 'taxon_name_id is required' do
      expect(observation_matrix_row_item.errors.include?(:taxon_name_id)).to be_truthy
    end

    specify 'type is MatrixRowItem::TaxonNameRowItem' do
      expect(observation_matrix_row_item.type).to eq('ObservationMatrixRowItem::Dynamic::TaxonName')
    end

    context 'other possible subclass attributes are nil' do
      specify 'collection_object_id' do
        observation_matrix_row_item.collection_object_id = FactoryBot.create(:valid_collection_object).id
        observation_matrix_row_item.valid?
        expect(observation_matrix_row_item.errors.include?(:collection_object_id)).to be_truthy
      end

      specify 'otu_id' do
        observation_matrix_row_item.otu_id = FactoryBot.create(:valid_otu).id
        observation_matrix_row_item.valid?
        expect(observation_matrix_row_item.errors.include?(:otu_id)).to be_truthy
      end
    end

    context 'with a observation_matrix_row_item saved' do
      let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }

      let!(:root) { FactoryBot.create(:root_taxon_name) } 
      let!(:t1) { Protonym.create(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
      let!(:t2) { Protonym.create(name: 'bus', rank_class: Ranks.lookup(:iczn, :genus), parent: t1)  }
      let!(:t3) { Protonym.create(name: 'cus', rank_class: Ranks.lookup(:iczn, :genus), parent: t2)  }

      let!(:o1) { Otu.create(taxon_name: t1) }

      before {
        observation_matrix_row_item.taxon_name = t1 
        observation_matrix_row_item.observation_matrix = observation_matrix
        observation_matrix_row_item.save!
      }

      specify '.otus' do
        expect(observation_matrix_row_item.otus).to contain_exactly(o1)
      end

      specify '.collection_objects' do
        expect(observation_matrix_row_item.collection_objects).to contain_exactly()
      end

      context 'adding an item synchronizes observation_matrix_rows' do
        specify 'saving a record adds otus observation_matrix_rows' do
          expect(ObservationMatrixRow.all.map(&:otu)).to contain_exactly(o1)
        end

        specify 'saving a record adds collection objects observation_matrix_rows' do
          expect(ObservationMatrixRow.all.map(&:collection_object)).to contain_exactly(nil)
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
          let!(:omri) { ObservationMatrixRowItem::Dynamic::TaxonName.create(taxon_name: t1, observation_matrix: om1) }

          specify 'saving a record adds otus observation_matrix_rows' do
            expect(ObservationMatrixRow.all.map(&:otu)).to contain_exactly(o1, o1)
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
        let!(:other_observation_matrix_row_item) { ObservationMatrixRowItem::Single::Otu.create!(observation_matrix: observation_matrix, otu: o1) }
        let(:observation_matrix_row) { ObservationMatrixRow.where(observation_matrix: observation_matrix, otu: o1).first} 

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
