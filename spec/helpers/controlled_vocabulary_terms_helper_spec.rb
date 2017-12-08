require 'rails_helper'

describe ControlledVocabularyTermsHelper, :type => :helper do
  context 'A controlled_vocabulary_term needs some helpers' do
    let(:controlled_vocabulary_term) { FactoryBot.create(:valid_controlled_vocabulary_term, name: name, definition: definition)}
    let(:name) {'helper term'}
    let(:definition) {'helper definition, the long version'}

    specify '::controlled_vocabulary_term_tag' do
      expect(helper.controlled_vocabulary_term_tag(controlled_vocabulary_term)).to match(name)
    end

    specify '#controlled_vocabulary_term_tag' do
      expect(helper.controlled_vocabulary_term_tag(controlled_vocabulary_term)).to match(name)
    end

    specify '#controlled_vocabulary_term_link' do
      expect(helper.controlled_vocabulary_term_link(controlled_vocabulary_term)).to have_link(name)
    end

    specify "#controlled_vocabulary_term_search_form" do
      expect(helper.controlled_vocabulary_terms_search_form).to have_field('controlled_vocabulary_term_id_for_quick_search_form')
    end

  end

end
