require 'rails_helper'

describe ControlledVocabularyTermsHelper, type: :helper do
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

    specify '#controlled_vocabulary_term_search_form' do
      expect(helper.controlled_vocabulary_terms_search_form).to have_field('controlled_vocabulary_term_id_for_quick_search_form')
    end

  end

  context '#controlled_vocabulary_term_use' do
    let(:project) { FactoryBot.create(:valid_project) }

    before do
      allow(helper).to receive(:sessions_current_project_id).and_return(project.id)
    end

    context 'for a BiocurationGroup' do
      specify 'returns the total number of classifications across all classes in the group, scoped to current project' do
        group = FactoryBot.create(:valid_biocuration_group, project: project)
        other_group  = FactoryBot.create(:valid_biocuration_group, project: project)

        klass1 = FactoryBot.create(:valid_biocuration_class, project: project)
        klass2 = FactoryBot.create(:valid_biocuration_class, project: project)
        klass3 = FactoryBot.create(:valid_biocuration_class, project: project)

        # Tag classes into groups
        FactoryBot.create(:valid_tag, tag_object: klass1, keyword: group,       project: project)
        FactoryBot.create(:valid_tag, tag_object: klass2, keyword: group,       project: project)
        FactoryBot.create(:valid_tag, tag_object: klass3, keyword: other_group, project: project)

        2.times do
          FactoryBot.create(
            :valid_biocuration_classification,
            project: project,
            biocuration_class: klass1
          )
        end

        FactoryBot.create(
          :valid_biocuration_classification,
          project: project,
          biocuration_class: klass2
        )

        # Not this one - different project.
        other_project = FactoryBot.create(:valid_project)
        FactoryBot.create(
          :valid_biocuration_classification,
          project: other_project,
          biocuration_class: klass1
        )

        # Expect: 2 (klass1) + 1 (klass2) = 3
        expect(helper.controlled_vocabulary_term_use(group)).to eq(3)
      end
    end

    # So we update the helper if/when we add a new class.
    specify 'does not return "n/a" for any ControlledVocabularyTerm subclass' do
      Rails.application.eager_load!

      ControlledVocabularyTerm.descendants.each do |cvt_class|
        term  = cvt_class.new
        value = helper.controlled_vocabulary_term_use(term)

        expect(value).not_to eq('n/a'), "expected #{cvt_class.name} not to hit the 'n/a' branch"
      end
    end
  end

end
