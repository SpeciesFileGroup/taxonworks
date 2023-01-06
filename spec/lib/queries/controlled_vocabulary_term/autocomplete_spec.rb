require 'rails_helper'

describe Queries::ControlledVocabularyTerm::Autocomplete, type: :model, group: [:annotations] do

  let!(:cvt1) { FactoryBot.create(:valid_keyword, name: 'Word 1') }
  let!(:cvt2) { FactoryBot.create(:valid_keyword, name: 'Wurd') }
  let!(:cvt3) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, name: 'urdicate') }
  let!(:cvt4) { FactoryBot.create(:valid_topic, name: 'wurdicate') }

  let!(:o1) { FactoryBot.create(:valid_otu) }
  let!(:o2) { FactoryBot.create(:valid_specimen) }
  let!(:o3) { FactoryBot.create(:valid_collecting_event) }

  let!(:t1) { Tag.create!(keyword: cvt1, tag_object: o1) }
  let!(:t2) { Tag.create!(keyword: cvt1, tag_object: o3) }

  let!(:q) { Queries::ControlledVocabularyTerm::Autocomplete.new('') }

  specify '#of_type' do
    q.controlled_vocabulary_term_type = ['Keyword']
    expect( q.all.to_a ).to contain_exactly(cvt1, cvt2) 
  end

  specify '#project_id' do
    q.controlled_vocabulary_term_type = ['Keyword']
    q.project_id = 99
    expect( q.all.to_a ).to contain_exactly() 
  end

end
