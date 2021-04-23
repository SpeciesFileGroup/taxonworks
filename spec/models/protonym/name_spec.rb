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
end
