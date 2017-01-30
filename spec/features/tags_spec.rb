require 'rails_helper'

describe 'Tags', type: :feature do
  let(:index_path) { tags_path }
  let(:page_index_name) { 'tags' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    let(:o) { Otu.create!(name: 'Cow', by: @user, project: @project) }
    let(:ce) {
      retval = CollectingEvent.create!(verbatim_label: 'Collecting a cow', by: @user, project: @project)
      retval
    }

    let(:keywords) do
      keywords = []
      ['slow', 'medium', 'fast'].each do |n|
        keywords.push FactoryGirl.create(:valid_keyword, name: n, by: @user, project: @project)
      end
      keywords
    end

    before do
      sign_in_user_and_select_project
    end

    let!(:tags) do
      tags = []
      (0..2).each do |i|
        tags.push Tag.create!(tag_object: o, keyword: keywords[i], by: @user, project: @project)
      end
      tags
    end

    describe 'GET /tags' do
      before { visit tags_path }
      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /tags/list' do
      before { visit list_tags_path }
      it_behaves_like 'a_data_model_with_standard_list'
    end

    context 'tagging a object through tag/new' do
      before { visit otu_path(o) }

      context 'using the annotation menu' do
        before do
          find('#show_annotate_dropdown').click
          click_link 'Add tag'
        end

        context 'I can create a new keyword inline', js: true do
          let(:tag_name) { 'Enormous' }

          before do
            fill_in('keyword_picker_autocomplete', with: tag_name)
            fill_in("#{o.class.name}_#{o.id}_new_keyword_definition", with: 'asdfasf asdf')
            find('#keyword_picker_add_new').click
            click_button('Update')
          end

          specify 'and the tag is added' do
            expect(o.tags.count).to eq(4) # since 3 already existed with reference to let!(:tags)
            expect(o.tags.first.keyword.name).to eq(tag_name)
          end

        end

      end


    end

    # pending 'clicking a tag link anywhere renders the tagged object in <some> view'

    describe 'the structure of tag_splat' do
      specify 'has a splat' do
        # ce = CollectingEvent.first
        visit("#{ce.class.name.tableize}/#{ce.id}")
        expect(find("#tag_splat_#{ce.class.name}_#{ce.id}").value).to have_text('Tag')
      end
    end

    # context 'using the splat old', js: true do
    #
    #   specify 'invoke the splat action' do
    #     visit("#{ce.class.name.tableize}/#{ce.id}")
    #     find("#tag_splat_#{ce.class.name}_#{ce.id}").click
    #   end
    #   before do
    #     fill_in('keyword_picker_autocomplete', with: 'slow')
    #     find('#keyword_picker_add_new').click
    #     click_button('Update')
    #   end
    #
    #   specify 'the collecting event should have a tag' do
    #     expect(ce.tags.count).to eq(1)
    #   end
    # end


    context 'using the splat', js: true do
      before do
        visit("#{ce.class.name.tableize}/#{ce.id}")
        find("#tag_splat_#{ce.class.name}_#{ce.id}").click
      end
      describe 'find existing keyword' do
        before do
          k = Keyword.find(1)
          fill_autocomplete('keyword_picker_autocomplete', with: 'slo', select: k.id)
          wait_for_ajax
          click_button('Update')
        end
        specify do
          expect(ce.tags.count).to eq(1)
        end
      end
    end
    # describe do
    #   specify do
    #
    #   end
    # end
  end

end

