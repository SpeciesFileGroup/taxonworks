require 'rails_helper'

describe Queries::ControlledVocabularyTerm::Autocomplete, type: :model, group: [:annotations] do

  let!(:cvt1) { FactoryBot.create(:valid_keyword, name: 'Word 1') }
  let!(:cvt2) { FactoryBot.create(:valid_keyword, name: 'Wurd') }
  let!(:cvt3) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate, name: 'urdicate') }
  let!(:cvt4) { FactoryBot.create(:valid_topic, name: 'wurdicate') }

  let!(:o1) { FactoryBot.create(:valid_otu) }
  let!(:o2) { FactoryBot.create(:valid_specimen) }
  let!(:o3) { FactoryBot.create(:valid_collecting_event) }

  let!(:t1) { FactoryBot.create(:valid_tag, keyword: cvt1, tag_object: o1) }
  let!(:t2) { FactoryBot.create(:valid_tag, keyword: cvt1, tag_object: o3) }

  let!(:q) { Queries::ControlledVocabularyTerm::Autocomplete.new('') }

  context 'of_type' do
    before { q.of_type = ['Keyword'] }
    specify 'of_type' do
      expect( q.all.to_a ).to contain_exactly(cvt1, cvt2) 
    end
  end

end
