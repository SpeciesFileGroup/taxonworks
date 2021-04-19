require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  let(:protonym) { Protonym.new }
  let(:root) { FactoryBot.create(:root_taxon_name, project_id: 1) }

  context 'possible homonyms' do
    before {protonym.type = 'Protonym'}

    context '#name_with_alternate_spelling' do
      alternate_spellings = {
        species:  {
          'rubbus' => 'ruba',
          'aiorum' => 'aora',
          'nigrocinctus' => 'nigricinta' # TODO: is this right?
        },
        family: {
          'Aini' => 'Aidae',
        }
      }

      alternate_spellings.each do |rank, comparison|
        context rank do
          before { protonym.rank_class = Ranks.lookup(:iczn, rank) } 
          comparison.each do |k,v|
            specify "#{k} returns #{v}" do
              protonym.name = k
              expect(protonym.name_with_alternative_spelling).to eq(v)
            end
          end 
        end
      end

      specify '(currently) fails when #family_group_base fails to match' do 
        protonym.rank_class = Ranks.lookup(:iczn, 'family')
        protonym.name = 'Ayni'
        expect(protonym.name_with_alternative_spelling).to eq('Ayni')
      end
    end
  end

  context 'misspelling' do
    let(:genus) { Protonym.new(name: 'Mus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }

    context 'ICZN names' do
      let(:s) { Protonym.new(parent: genus, rank_class: Ranks.lookup(:iczn, :species) ) }
      context 'legal forms' do
        legal = ['vitis', 'a-aus'] 
        legal.each do |l|
          specify l do
            s.name = l 
            s.soft_validate(only_sets: :validate_name)
            expect(s.soft_validations.messages_on(:name).empty?).to be_truthy
          end
        end
      end

      context 'illegal forms' do
        illegal = ['aus-aus'] 
        illegal.each do |l|
          specify l do
            s.name = l 
            s.soft_validate(only_sets: :validate_name)
            expect(s.soft_validations.messages_on(:name).empty?).to be_falsey
          end
        end
      end
    end
  end
end
