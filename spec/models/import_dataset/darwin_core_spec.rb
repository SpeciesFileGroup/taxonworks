require 'rails_helper'

RSpec.describe ImportDataset::DarwinCore, type: :model do
  let(:source) { fixture_file_upload(Rails.root.join('spec/files/import_datasets/literal_quotes.tsv'), 'text/tab-separated-values') }
  let(:localities) do
    ["Windsor Castle, 12°13'25\"S 49°10'06\"E", 'Windsor Castle "karst" plateau']
  end

  def detect_dataset(source, settings)
    described_class.create_with_subtype_detection(
      {
        source: source,
        description: 'Literal quotes regression',
        import_settings: settings
      }.with_indifferent_access
    )
  end

  it 'preserves literal quotes through subtype detection, validation, reload, and staging' do
    dataset = detect_dataset(source, col_sep: "\t", quote_char: 'none')

    expect(dataset).to be_a(ImportDataset::DarwinCore::Occurrences)
    dataset.save!
    dataset.reload
    expect(dataset.metadata.dig('import_settings', 'quote_char')).to eq('none')
    dataset.stage

    expect(dataset.status).to eq('Ready')
    records = dataset.core_records.order(:id).to_a
    expect(records.size).to eq(2)
    expect(records.map { |r| r.get_field_value('verbatimLocality') }).to eq(localities)
    expect(records.map { |r| r.get_field_value('decimalLatitude') }).to eq(['-12.214683'] * 2)
    expect(records.map { |r| r.get_field_value('EventDate') }).to eq(['2026-09-02'] * 2)
  end

  [nil, '', '"', "'"].each do |quote_setting|
    it "parses enclosed fields with quote setting #{quote_setting.inspect}" do
      quote = quote_setting.presence || '"'
      locality = "Castle, #{quote}karst#{quote}\nplateau"
      content = CSV.generate(quote_char: quote) do |csv|
        csv << %w[occurrenceID basisOfRecord scientificName verbatimLocality]
        csv << ['1', 'PreservedSpecimen', 'Animalia', locality]
      end

      Tempfile.create(['quoted_occurrences', '.csv']) do |file|
        file.write(content)
        file.flush
        upload = Rack::Test::UploadedFile.new(file.path, 'text/csv')
        settings = { col_sep: ',' }
        settings[:quote_char] = quote_setting unless quote_setting.nil?
        dataset = detect_dataset(upload, settings)

        expect(dataset).to be_a(ImportDataset::DarwinCore::Occurrences)
        dataset.save!
        dataset.reload
        dataset.stage
        expect(dataset.core_records.first.get_field_value('verbatimLocality')).to eq(locality)
      end
    end
  end

  it 'stages TaxonWorks TSV output with the default quote setting' do
    localities = ['Windsor Castle "karst" plateau', "Castle\tplateau", "Castle\nplateau"]
    rows = [%w[occurrenceID basisOfRecord scientificName verbatimLocality]]
    localities.each_with_index do |locality, index|
      rows << [(index + 1).to_s, 'PreservedSpecimen', 'Animalia', locality]
    end

    Tempfile.create(['taxonworks_occurrences', '.tsv']) do |file|
      file.write(Export::Dwca.output_csv(rows))
      file.flush
      upload = Rack::Test::UploadedFile.new(file.path, 'text/tab-separated-values')
      dataset = detect_dataset(upload, col_sep: "\t")

      expect(dataset).to be_a(ImportDataset::DarwinCore::Occurrences)
      dataset.save!
      dataset.reload
      dataset.stage

      expect(dataset.core_records.order(:id).map { |r| r.get_field_value('verbatimLocality') }).to eq(localities)
    end
  end

  it 'stages a checklist after persistence without duplicate metadata keys' do
    dataset = ImportDataset::DarwinCore::Checklist.create!(
      source: fixture_file_upload(Rails.root.join('spec/files/import_datasets/checklists/parent_child.tsv'), 'text/plain'),
      description: 'Checklist staging regression'
    )
    dataset.reload
    dataset.stage

    expect(dataset.reload.status).to eq('Ready')
    expect(dataset.metadata['core_headers']).to include('taxonID', 'scientificName')
    expect(dataset.metadata['extensions_headers']).to eq({})
    expect(dataset.core_records.count).to eq(2)
  end

  [ImportDataset::DarwinCore::Occurrences, ImportDataset::DarwinCore::Checklist].each do |klass|
    it "updates persisted #{klass.name.demodulize} settings using symbol and string keys" do
      fixture = klass == ImportDataset::DarwinCore::Checklist ? 'checklists/parent_child.tsv' : 'occurrences/collector_ids.tsv'
      dataset = klass.create!(
        source: fixture_file_upload(Rails.root.join('spec/files/import_datasets', fixture), 'text/plain'),
        description: 'Import settings key regression',
        import_settings: { quote_char: 'none', nomenclatural_code: 'iczn' }
      )
      dataset.reload
      dataset.set_import_settings(quote_char: '"')
      dataset.save!
      expect(dataset.reload.metadata['import_settings']).to eq({ 'quote_char' => '"', 'nomenclatural_code' => 'iczn' })

      dataset.set_import_settings('quote_char' => "'")
      dataset.save!
      expect(dataset.reload.metadata['import_settings']).to eq({ 'quote_char' => "'", 'nomenclatural_code' => 'iczn' })
    end
  end

end
