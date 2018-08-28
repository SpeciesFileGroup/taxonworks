require 'rails_helper'

describe BatchLoad::Import::Otus, type: :model do

  let(:file_name) { 'spec/files/batch/otu/OtuTest.tsv' }
  let(:setup) {
    csv1 = CSV.read(file_name, {
      headers:           true,
      header_converters: :downcase,
      col_sep:           "\t",
      encoding:          'UTF-8'})

    csv1.each do |row|
      ident = row[0]
      case ident
      when 'americana' # create an otu to find later
        Otu.create(name: ident)
      else
      end
    end
  }
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  let(:upload_file) { fixture_file_upload(file_name) }
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

  specify '.preview does not create otus (?!)' do
    import
    expect(Otu.count).to eq(1)
  end

  specify '.create create otus'  do
    import.create
    expect(Otu.count).to eq(7)
  end
end
