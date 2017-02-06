# Test basic functionality of data models with shared views, e.g., forward/back, list, download, etc.

shared_examples 'a_data_model_with_standard_index' do | no_new_link |
  specify 'has model name' do
    expect(page).to have_content(page_title)
   end

  if no_new_link
    specify "does not have new link" do
      expect(page).to_not have_link('New')
    end
  else
    specify "has new link" do
      expect(page).to have_link('New')
    end
  end

  specify "has list link" do
    expect(page).to have_link('List')
  end
  specify "has download link" do
    expect(page).to have_link('Download')
  end
  specify "has Recent updates" do
    expect(page).to have_text('Recent updates')
  end
end

# annotations_index does not have 'new'
shared_examples 'a_data_model_with_annotations_index' do
  specify 'has model name' do
    expect(page).to have_content(page_title)
  end

  specify "has list link" do
    expect(page).to have_link('List')
  end
  specify "has download link" do
    expect(page).to have_link('Download')
  end
  specify "has Recent updates" do
    expect(page).to have_text('Recent updates')
  end
end

shared_examples 'a_data_model_with_standard_list_and_records_created' do
  specify 'displays the total' do
    expect(page).to have_css("div", text: /Displaying.*#{page_title.downcase}/)
    expect(page).to have_css("div", text: /Displaying.*\d+/)
  end
end

shared_examples 'a_data_model_with_standard_show' do
  specify 'has a Previous link' do
    expect(page).to have_link('Previous')
  end

  specify 'has a Next link' do
    expect(page).to have_link('Next')
  end
end
