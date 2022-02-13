require 'rails_helper'

describe TaxonName, typein_scope_observation_matrix_row_items: :model, group: [:observation_matrix] do

  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:family) { Protonym.create!(name: 'Traidae', parent: root, rank_class: Ranks.lookup(:iczn, :family)) }

  let!(:genus1) { Protonym.create!(name: 'Train', parent: family, rank_class: Ranks.lookup(:iczn, :genus)) }
  let!(:species) { Protonym.create!(name: 'teeus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) }

  let!(:genus2) { Protonym.create!(name: 'Boat', parent: family, rank_class: Ranks.lookup(:iczn, :genus)) }

  let!(:observation_matrix) { ObservationMatrix.create!(name: 'foo')  }
  
  let!(:otu) { Otu.create!(taxon_name: species) }

  context 'setup' do
    let!(:d) { ::ObservationMatrixRowItem::Dynamic::TaxonName.create!( observation_matrix: observation_matrix, taxon_name: genus1 )}

    # NOTE: Specs in this block should also work if :otu is created in this position

    specify 'creating a member adds to matrix' do
      expect(observation_matrix.observation_matrix_rows.reload.count).to eq(1)
    end

    context 'member' do
      specify '#member_update_matrix_items? 1' do
        expect(otu.member_update_matrix_items?('row')).to be_falsey
      end

      specify '#member_update_matrix_items? 2' do
        otu.taxon_name_id = nil 
        expect(otu.member_update_matrix_items?('row')).to be_truthy
      end

      specify '#member_remove_from_matrix_items("row") 1' do
        expect(otu.member_remove_from_matrix_items('row')).to contain_exactly()
      end

      specify '#member_remove_from_matrix_items 2' do
        otu.taxon_name_id = nil 
        expect(otu.member_remove_from_matrix_items('row')).to contain_exactly(d)
      end

      specify '#member_of_old_matrix_row_items 1' do
        otu.taxon_name_id = nil 
        expect(otu.member_of_old_matrix_row_items).to contain_exactly(d)
      end

      specify '#member_of_new_matrix_row_items 1' do
        otu.taxon_name_id = nil 
        expect(otu.member_of_new_matrix_row_items).to contain_exactly()
      end

      specify 'move out of scope 1' do
        otu.update(taxon_name: nil, name: 'out of scope')
        expect(observation_matrix.observation_matrix_rows.count).to eq(0)
      end

      specify 'move out of scope 2' do
        otu.update(taxon_name: genus2)
        expect(observation_matrix.observation_matrix_rows.count).to eq(0)
      end
    end

    context 'add species' do
      let!(:d) { ::ObservationMatrixRowItem::Dynamic::TaxonName.create!( observation_matrix: observation_matrix, taxon_name: genus1 )}
      let!(:species2) { Protonym.create!(name: 'gus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) }
      let!(:otu2) { Otu.create!(taxon_name: species2) }

      specify 'adding species to scope 1' do
        expect(observation_matrix.observation_matrix_rows.count).to eq(2)
      end

      specify 'adding species to scope 2' do
        expect(observation_matrix.observation_matrix_rows.map(&:observation_object)).to contain_exactly(otu, otu2)
      end

      specify 'otus can be destroyed' do
        expect(otu2.destroy!).to be_truthy
      end
    end

    context 'dynamic' do
      let!(:species2) { Protonym.create!(name: 'gus', parent: genus2, rank_class: Ranks.lookup(:iczn, :species)) }

      let!(:otu2) { Otu.create!(taxon_name: species2) }

      specify '#coordinate_observation_matrix_row_items' do
        expect(species2.coordinate_observation_matrix_row_items).to contain_exactly()
      end

      specify '#in_scope_observation_matrix_row_items' do
        species2.parent_id = genus1.id
        expect(species2.in_scope_observation_matrix_row_items).to contain_exactly(d)
      end

      specify '#dynamic_update_matrix_row_items' do
        expect(species2.dynamic_update_matrix_row_items?).to be_falsey
      end

      specify 'exit scope' do
        species.update(parent: genus2) # Otu is not in scope
        expect(observation_matrix.observation_matrix_rows.count).to eq(0)
      end

      specify '#otus 1' do
        expect(d.row_objects).to contain_exactly(otu)
      end

      specify '#otus 2' do
        species2.update(parent: genus1)
        expect(d.row_objects).to contain_exactly(otu, otu2)
      end

      specify '#row_objects' do
        species2.update(parent: genus1)
        expect(d.row_objects).to contain_exactly(otu, otu2)
      end

      specify '#row_objects 2' do
        species2.update!(parent: species, rank_class: Ranks.lookup(:iczn, :subspecies))
        expect(d.row_objects).to contain_exactly(otu, otu2)
      end

      specify 'enter scope' do
        species2.update(parent: genus1)
        expect(observation_matrix.observation_matrix_rows.reload.count).to eq(2) # contains otu1 and otu2
      end

      specify 'enter scope 2' do
        species2.update!(parent: species, rank_class: Ranks.lookup(:iczn, :subspecies))
        expect(observation_matrix.observation_matrix_rows.reload.count).to eq(2) # contains otu1 and otu2
      end

      specify 'move, but remain in scope' do
        sub_genus = Protonym.create!(name: 'Goat', parent: genus2, rank_class: Ranks.lookup(:iczn, :subgenus))
        species2.update!(parent: sub_genus)
        expect(observation_matrix.observation_matrix_rows.reload.count).to eq(1)
      end
    end

    context 'overlapping' do
      let(:keyword) { FactoryBot.create(:valid_keyword) }
      let!(:t) { ::ObservationMatrixRowItem::Dynamic::Tag.create!( observation_matrix: observation_matrix, controlled_vocabulary_term: keyword )}

      specify 'dynamic groups increment count' do
        Tag.create!(keyword: keyword, tag_object: otu)
        expect(ObservationMatrixRow.first.reference_count).to eq(2)
      end
    end
  end

  # TODO: move to tag matrix hook specs
  context 'tag alone' do
    let(:keyword) { FactoryBot.create(:valid_keyword) }
    let!(:t) { ::ObservationMatrixRowItem::Dynamic::Tag.create!( observation_matrix: observation_matrix, controlled_vocabulary_term: keyword )}
    
    specify 'dynamic groups increment count' do
      Tag.create!(keyword: keyword, tag_object: otu) 
      expect(ObservationMatrixRow.first.reference_count).to eq(1)
    end
  end

end
