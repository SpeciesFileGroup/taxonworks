require 'rails_helper'

describe BatchLoad::Import::Otus, type: :model do

  let(:file_name) { 'spec/files/batch/otu/OtuTest.tsv' }
  let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  let(:setup) {
    csv1 = CSV.read(file_name,
      headers:           true,
      header_converters: :downcase,
      col_sep:           "\t",
      encoding:          'UTF-8')

    csv1.each do |row|
      ident = row[0]
      case ident
      when 'americana' # create an otu to find later
        Otu.create(name: ident)
      else
      end
    end
  }

  let(:import) { BatchLoad::Import::Otus.new(
    project_id: project.id,
    user_id: user.id,
    file: upload_file)
  }

  before { setup }

  specify 'baseline is 1' do
    expect(Otu.count).to eq(1)
  end

  specify '.new succeeds' do
    expect(import).to be_truthy
  end

  specify '#processed_rows' do
    expect(import.processed_rows.count).to eq(7) # now skips empties
  end

  specify '#processed_rows' do
    expect(import.create_attempted).to eq(false)
  end

  context 'after .create' do
    before { import.create }
  
    specify '#create_attempted' do
      expect(import.create_attempted).to eq(true)
    end
 
    specify '#valid_objects' do
      expect(import.valid_objects.count).to eq(7)
    end

    specify '#successful_rows' do
      expect(import.successful_rows).to be_truthy
    end

    specify '#total_records_created' do
      expect(import.total_records_created).to eq(7)
    end
  end



end
