# Test basic functionality of data models with shared views, e.g., forward/back, list, download, etc.
shared_examples 'a_data_model_with_standard_index' do
  specify 'has model name' do
    expect(page).to have_content(page_index_name)
  end

  specify "has new link" do
    expect(page).to have_link('new')
  end
  specify "has list link" do
    expect(page).to have_link('list')
  end
  specify "has download link" do
    expect(page).to have_link('download')
  end
  specify "has Recent updates" do
    expect(page).to have_text('Recent updates')
  end
end

shared_examples 'a_data_model_with_standard_list' do
  specify 'renders without error' do
    expect(page).to have_content "Listing #{page_index_name}"
  end

  specify 'displays the total' do
    expect(page).to have_css("div", text: /Displaying all \d+ #{page_index_name.downcase}/)
  end

  # specify "there to be 'First', 'Prev', 'Next', and 'Last' links" do
  #   # click_link('Next')
  #   # expect(page).to have_link('First')
  #   # expect(page).to have_link('Prev')
  #   # expect(page).to have_link('Next')
  #   # expect(page).to have_link('Last')
  # end
  # end
end

shared_examples 'a_data_model_with_standard_show' do
  specify 'has a Previous link' do
    expect(page).to have_link('Previous')
  end

  specify 'has a Next link' do
    expect(page).to have_link('Next')
  end
end
