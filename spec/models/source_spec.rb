require 'spec_helper'

describe Source do
  let(:source) { Source.new }

  before do
    @bibtex_records = BibTeX.open(Rails.root + "spec/files/Taenionema.bib")
  end

  context "BibTeX configuration" do
    specify "the test file should have 42 records" do
      expect(@bibtex_records.size).to eq(42)
    end

    specify "the first record has 4 fields populated" do
      expect(@bibtex_records.first.fields.keys.size).to eq(4)
    end

    specify "title of first record is 'A Monograph of the Plecoptera or Stoneflies of America North of America'" do
      expect(@bibtex_records.first.title).to eq('A Monograph of the Plecoptera or Stoneflies of America North of America')
    end

    specify "first record pubtype is 'book'" do
      expect(@bibtex_records.first.type).to eq(:book)
    end

    specify "first record address is 'Lafayette, {IN}'" do
      expect(@bibtex_records.first.address).to eq('Lafayette, {IN}')
    end

    specify "first record publisher is 'The Thomas Say Foundation'" do
      expect(@bibtex_records.first.publisher).to eq('The Thomas Say Foundation')
    end

    specify "first record author is 'Needham, James G. and Claassen, Peter W.'" do
      expect(@bibtex_records.first.author).to eq('Needham, James G. and Claassen, Peter W.')
    end

    specify "second record pubtype is 'article'" do
      expect(@bibtex_records[1].type).to eq(:article)
    end

    specify "second record volume is '53'" do
      expect(@bibtex_records[1].volume).to eq('53')
    end

    specify "second record issn is '1480-3283'" do
      expect(@bibtex_records[1].issn).to eq('1480-3283')
    end

    specify "second record number is '2.'" do
      expect(@bibtex_records[1].number).to eq('2')
    end

    specify "second record journal is 'Canadian Journal of Zoology'" do
      expect(@bibtex_records[1].journal).to eq('Canadian Journal of Zoology')
    end

    specify "second record year is '1975'" do
      expect(@bibtex_records[1].year).to eq('1975')
    end

    specify "second record pages is '132–153'" do
      expect(@bibtex_records[1].pages).to eq('132–153')
    end

    specify "fourth record pubtype is 'incollection'" do
      expect(@bibtex_records[3].type).to eq(:incollection)
    end

    specify "fourth record booktitle is 'International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies'" do
      expect(@bibtex_records[3].booktitle).to eq('International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies')
    end

    specify "last record edition is 'Fourth'" do
      expect(@bibtex_records[-1].edition).to eq('Fourth')
    end

    specify "last record url is 'http://www.nhm.ac.uk/hosted-sites/iczn/code/'" do
      expect(@bibtex_records[-1].url).to eq('http://www.nhm.ac.uk/hosted-sites/iczn/code/')
    end

    specify "last record urldate is '2010-12-06'" do
      expect(@bibtex_records[-1].urldate).to eq('2010-12-06')
    end
  end

  context "on save" do
    before do
      # source.update_attributes(@bibtex_records.first.to_hash)
      source.save
    end
  end

  context "instance methods" do
    pending "source_to_bibtex to create valid bibtex record"
  end

end
