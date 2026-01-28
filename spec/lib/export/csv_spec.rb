require 'rails_helper'
require 'export/dwca'

describe Export::Dwca, type: :model do
  include ActiveJob::TestHelper

  context 'copy_column' do
    let!(:core_scope) { DwcOccurrence.where(project_id: Project.first.id) }
    let(:csv_string) {
      ::Export::CSV.generate_csv(
        core_scope.computed_occurrence_columns,
        exclude_columns: ::DwcOccurrence.excluded_occurrence_columns,
        column_order: ::CollectionObject::DWC_OCCURRENCE_MAP.keys + ::CollectionObject::EXTENSION_FIELDS,
        trim_columns: true,
        trim_rows: false,
        header_converters: [:dwc_headers],
        copy_column: { from: 'occurrenceID', to: 'id' }
      )
    }
    let(:csv) { CSV.parse(csv_string, headers: true, col_sep: "\t") }

    before do
      5.times do
        f = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event))
        f.get_dwc_occurrence
      end
    end

    specify 'header copy_to column name stays the same' do
      expect(csv.headers.include?('id')).to be_truthy
    end

    specify 'column data is copied' do
      expect(csv.count).to eq(5)

      csv do |row|
        expect(row['id']).to eq(row['occurrenceID'])
      end
    end
  end

end