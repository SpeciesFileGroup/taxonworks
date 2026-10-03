require 'rails_helper'

describe 'DwC-A import delimiters', type: :feature, js: true do
  before do
    sign_in_user_and_select_project
    visit dwca_import_task_path
    within('.block-layout', text: 'New import') do
      find('input[type="text"]').set('Literal quotes browser regression')
    end
  end

  it 'keeps the TSV double quote default and uploads literal quotes after selecting None' do
    attach_file(
      Rails.root.join('spec/files/import_datasets/literal_quotes.tsv'),
      make_visible: true
    )

    expect(page).to have_checked_field('Tab')
    expect(find('label', text: '"', exact_text: true).find('input')).to be_checked
    choose 'None'
    click_button 'Upload'

    expect(page).to have_button('Back')
    dataset = ImportDataset.find_by!(description: 'Literal quotes browser regression')
    expect(dataset).to be_a(ImportDataset::DarwinCore::Occurrences)
    expect(dataset.metadata.dig('import_settings', 'quote_char')).to eq('none')
    ImportDatasetStageJob.perform_now(dataset)
    expect(dataset.core_records.order(:id).map { |r| r.get_field_value('verbatimLocality') }).to eq(
      ["Windsor Castle, 12°13'25\"S 49°10'06\"E", 'Windsor Castle "karst" plateau']
    )
  end

  it 'keeps the comma and double quote defaults for CSV' do
    Tempfile.create(['quoted_occurrences', '.csv']) do |file|
      file.write("occurrenceID,basisOfRecord,scientificName\n1,PreservedSpecimen,Animalia\n")
      file.flush
      attach_file(file.path, make_visible: true)

      expect(page).to have_checked_field('Comma')
      expect(find('label', text: '"', exact_text: true).find('input')).to be_checked
    end
  end
end
