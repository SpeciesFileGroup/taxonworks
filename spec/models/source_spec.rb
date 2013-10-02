require 'spec_helper'

describe Source do
  let(:source) { Source.new }

  before do
    @bibtex_file = File.read(Rails.root + "spec/files/Taenionema.bib")
    @bibtex_records = 'Beth, figure it out!  Is this an array of all records? We need to cycle through them.'
  end

  context "Bibtex configuration" do
    specify "if read properly, titles should match" do
      expect(@bibtex_records.first.title).to eq('A Monograph of the Plecoptera or Stoneflies of America North of America')
    end
    specify "first record pubtype is 'book'"
    specify "first record address is 'Lafayette, IN'"
    specify "first record publisher is 'The Thomas Say Foundation'"
    specify "first record author is 'Needham, James G. and Claassen, Peter W.'"
    specify "second record pubtype is 'article'"
    specify "second record volume is '53'"
    specify "second record issn is '1480-3283'"
    specify "second record number is '2.'"
    specify "second record journal is 'Canadian Journal of Zoology'"
    specify "second record year is '1975'"
    specify "second record pages is '132–153'"
    specify "fourth record pubtype is 'incollection'"
    specify "fourth record booktitle is 'International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies'"
    specify "last record edition is 'Fourth'"
    specify "last record url is 'http://www.nhm.ac.uk/hosted-sites/iczn/code/'"
    specify "last record urldate is '2010-12-06'"
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
