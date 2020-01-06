require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  let(:root) { Protonym.create!(name: 'Root', rank_class: NomenclaturalRank, parent_id: nil) }

  let(:protonym) { Protonym.new }

  let(:source) { FactoryBot.create(:valid_source_bibtex, year: 1940, author: 'Dmitriev, D.')   }

  let(:p1) { Person.create!(last_name: 'Smith') }
  let(:p2) { Person.create!(last_name: 'Jones') }
  let(:p3) { Person.create!(last_name: 'Herbert') }

  specify '#author_string' do
    expect(root.author_string).to eq(nil)
  end

  context 'by nested attributes' do
    let(:name) {
      Protonym.create!(
        name: 'aus', 
        parent: root, 
        rank_class: Ranks.lookup(:iczn, :species), 
        taxon_name_author_roles_attributes: [
          {person_id: p1.id},
          {person: p2},
          {person_id: p3.id}])}

    specify '#author_string' do
      expect(name.author_string).to eq('Smith, Jones & Herbert')
    end
  end

  context 'updating roles' do
    let(:name) {
      Protonym.create!(
        name: 'aus', 
        parent: root, 
        rank_class: Ranks.lookup(:iczn, :species), 
        taxon_name_author_roles_attributes: [
          {person_id: p1.id}])}
    let(:first_role_id) {name.taxon_name_author_roles.first.id }
    
    specify '#author_string 1' do
      name.update(taxon_name_author_roles_attributes: [{_destroy: true, id: first_role_id}, {person: p2}])
      expect(name.author_string).to eq('Jones')
    end

   specify '#author_string 2' do
     name.update(roles_attributes: [{_destroy: true, id: first_role_id}, {type: 'TaxonNameAuthor', person: p2}])
     expect(name.author_string).to eq('Jones')
   end
  end

end
