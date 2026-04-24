require 'rails_helper'

describe Utilities::DarwinCore::Table do

  let(:tsv_headers) { "catalogNumber\tscientificName\tindividualCount\tsex\tlifeStage\totherCatalogNumbers\teventDate" }

  let(:tsv_row_1) { "ABC-001\tAus bus\t2\tmale\tadult\tXYZ-1\t2024-01-15" }
  let(:tsv_row_2) { "ABC-001\tAus bus\t3\tfemale\tadult\tXYZ-2\t2024-01-15" }
  let(:tsv_row_3) { "ABC-002\tCus dus\t1\tmale\tadult\tXYZ-3\t2024-03-20" }

  let(:tsv_string) { [tsv_headers, tsv_row_1, tsv_row_2, tsv_row_3].join("\n") + "\n" }

  context 'initialization' do
    specify 'from tsv_string' do
      table = Utilities::DarwinCore::Table.new(tsv_string:)
      expect(table.headers).to include('catalogNumber', 'scientificName')
      expect(table.rows.size).to eq(3)
    end

    specify 'from csv object' do
      csv = CSV.parse(tsv_string, col_sep: "\t", headers: true)
      table = Utilities::DarwinCore::Table.new(csv:)
      expect(table.headers).to include('catalogNumber')
      expect(table.rows.size).to eq(3)
    end

    specify 'from file' do
      tmpfile = Tempfile.new(['dwc_test', '.tsv'])
      tmpfile.write(tsv_string)
      tmpfile.rewind
      table = Utilities::DarwinCore::Table.new(file: tmpfile.path)
      expect(table.rows.size).to eq(3)
      tmpfile.close!
    end

    specify 'raises with no arguments' do
      expect { Utilities::DarwinCore::Table.new }.to raise_error(ArgumentError)
    end

    specify 'raises with multiple arguments' do
      csv = CSV.parse(tsv_string, col_sep: "\t", headers: true)
      expect { Utilities::DarwinCore::Table.new(csv:, tsv_string:) }.to raise_error(ArgumentError)
    end
  end

  context 'output' do
    let(:table) { Utilities::DarwinCore::Table.new(tsv_string:) }

    specify '#to_tsv returns a TSV string' do
      output = table.to_tsv
      lines = output.strip.split("\n")
      expect(lines.size).to eq(4) # header + 3 rows
      expect(lines.first.split("\t")).to include('catalogNumber')
    end

    specify '#to_csv returns a CSV object' do
      csv = table.to_csv
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to include('catalogNumber')
      expect(csv.size).to eq(3)
    end

    specify '#to_file writes a TSV file' do
      tmpfile = Tempfile.new(['dwc_output', '.tsv'])
      path = tmpfile.path
      tmpfile.close!
      table.to_file(path)
      content = File.read(path)
      expect(content.split("\n").size).to eq(4)
      File.delete(path)
    end
  end

  context '#compact' do
    specify 'raises on unknown strategy' do
      table = Utilities::DarwinCore::Table.new(tsv_string:)
      expect { table.compact(by: :unknown) }.to raise_error(ArgumentError)
    end
  end
end
