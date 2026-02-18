require 'rails_helper'

describe Utilities::DarwinCore::Compact do

  let(:tsv_headers) { "catalogNumber\tscientificName\tindividualCount\tsex\tlifeStage\totherCatalogNumbers\teventDate\tcountry" }

  let(:tsv_row_male) { "ABC-001\tAus bus\t2\tmale\tadult\tXYZ-1\t2024-01-15\tUSA" }
  let(:tsv_row_female) { "ABC-001\tAus bus\t3\tfemale\tadult\tXYZ-2\t2024-01-15\tUSA" }
  let(:tsv_row_single) { "ABC-002\tCus dus\t1\tmale\tadult\tXYZ-3\t2024-03-20\tCanada" }

  let(:basic_tsv) { [tsv_headers, tsv_row_male, tsv_row_female, tsv_row_single].join("\n") + "\n" }

  context 'compact_by_catalog_number' do
    specify 'merges rows with identical catalogNumber' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      expect(table.rows.size).to eq(2)
    end

    specify 'sums individualCount' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      merged = table.rows.find { |r| r['catalogNumber'] == 'ABC-001' }
      expect(merged['individualCount']).to eq('5')
    end

    specify 'appends sex values with delimiter' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      merged = table.rows.find { |r| r['catalogNumber'] == 'ABC-001' }
      expect(merged['sex']).to eq('male|female')
    end

    specify 'appends lifeStage values uniquely' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      merged = table.rows.find { |r| r['catalogNumber'] == 'ABC-001' }
      expect(merged['lifeStage']).to eq('adult')
    end

    specify 'appends otherCatalogNumbers' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      merged = table.rows.find { |r| r['catalogNumber'] == 'ABC-001' }
      expect(merged['otherCatalogNumbers']).to eq('XYZ-1|XYZ-2')
    end

    specify 'computes adultMale derived column' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      merged = table.rows.find { |r| r['catalogNumber'] == 'ABC-001' }
      expect(merged['adultMale']).to eq('2')
    end

    specify 'computes adultFemale derived column' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      merged = table.rows.find { |r| r['catalogNumber'] == 'ABC-001' }
      expect(merged['adultFemale']).to eq('3')
    end

    specify 'computes immatureNymph derived column' do
      tsv = [tsv_headers, "ABC-003\tEus fus\t4\tmale\tnymph stage 3\tXYZ-4\t2024-05-01\tUSA"].join("\n") + "\n"
      table = Utilities::DarwinCore::Table.new(tsv_string: tsv)
      table.compact(by: :catalog_number)
      row = table.rows.first
      expect(row['immatureNymph']).to eq('4')
    end

    specify 'computes exuvia derived column' do
      tsv = [tsv_headers, "ABC-004\tGus hus\t2\tfemale\texuvia\tXYZ-5\t2024-06-01\tUSA"].join("\n") + "\n"
      table = Utilities::DarwinCore::Table.new(tsv_string: tsv)
      table.compact(by: :catalog_number)
      row = table.rows.first
      expect(row['exuvia']).to eq('2')
    end

    specify 'adds derived column headers' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      expect(table.headers).to include('adultMale', 'adultFemale', 'immatureNymph', 'exuvia')
    end

    specify 'single rows still get derived columns' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number)
      single = table.rows.find { |r| r['catalogNumber'] == 'ABC-002' }
      expect(single['adultMale']).to eq('1')
      expect(single['adultFemale']).to eq('0')
    end
  end

  context 'preview mode' do
    specify 'does not modify rows' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number, preview: true)
      expect(table.rows.size).to eq(3) # unchanged
    end

    specify 'does not add derived headers' do
      table = Utilities::DarwinCore::Table.new(tsv_string: basic_tsv)
      table.compact(by: :catalog_number, preview: true)
      expect(table.headers).not_to include('adultMale')
    end
  end

  context 'error logging' do
    specify 'logs error when non-operated columns differ' do
      tsv = [
        tsv_headers,
        "ABC-001\tAus bus\t2\tmale\tadult\tXYZ-1\t2024-01-15\tUSA",
        "ABC-001\tAus bus\t3\tfemale\tadult\tXYZ-2\t2024-01-15\tCanada"
      ].join("\n") + "\n"
      table = Utilities::DarwinCore::Table.new(tsv_string: tsv)
      table.compact(by: :catalog_number, preview: true)
      error = table.errors.find { |e| e[:type] == :error && e[:column] == 'country' }
      expect(error).to be_present
      expect(error[:values]).to contain_exactly('USA', 'Canada')
    end

    specify 'warns for non-adult lifeStage' do
      tsv = [
        tsv_headers,
        "ABC-005\tIus jus\t1\tmale\tlarva\tXYZ-6\t2024-07-01\tUSA",
        "ABC-005\tIus jus\t1\tfemale\tlarva\tXYZ-7\t2024-07-01\tUSA"
      ].join("\n") + "\n"
      table = Utilities::DarwinCore::Table.new(tsv_string: tsv)
      table.compact(by: :catalog_number, preview: true)
      warning = table.errors.find { |e| e[:type] == :warning && e[:column] == 'lifeStage' }
      expect(warning).to be_present
    end
  end
end
