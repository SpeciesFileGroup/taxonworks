require 'rails_helper'

describe 'Compositions smoke', type: :feature do
  before { sign_in_user_and_select_project }

  specify 'pages render' do
    l = Layout.create!(name: 'Table', by: @user, project: @project)
    l2 = Layout.create!(name: 'Table 2', by: @user, project: @project)
    n = News::Project::Notice.create!(title: 'Hi', body: 'There', project: @project, by: @user, display_start: 1.day.ago, display_end: 1.day.from_now) rescue nil

    visit composition_path(l)
    expect(page).to have_content('Table')
    expect(Layout.new.respond_to?(:pinboard_items)).to be_falsey
    visit composition_path(l2)
    expect(page).to have_content('Table 2')
    visit list_compositions_path
    expect(page).to have_content('Table 2')
    visit compositions_path
    expect(page.status_code).to eq(200)
    visit composition_path(l, format: :json)
    expect(page.body).to include('"name":"Table"')
    visit "/compositions.json?per=1"
    expect(page.response_headers['Pagination-Total-Pages'] || page.response_headers['pagination-total-pages']).to be_present
    visit edit_composition_path(l)
    expect(page.status_code).to eq(200)
    if n
      visit news_path(n.metamorphosize) rescue nil
    end
    visit list_news_index_path rescue visit news_index_path
    expect(page.status_code).to eq(200)
  end
end
