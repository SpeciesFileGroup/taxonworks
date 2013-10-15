require 'spec_helper'

describe Source::Bibtex do

  let(:bibtex) { Source::Bibtex.new }

  before do
    @bibtex_bibliography = BibTeX.open(Rails.root + "spec/files/Taenionema.bib")
    @simple1 = BibTeX::Entry.new() 
    @simple2 = BibTeX::Entry.new() 
    @entry1 = BibTeX::Entry.new(type: :book, title: "Foos of Bar America", author: "Smith, James", year: 1921) 
    @entry2 = BibTeX::Entry.new(type: :book, title: "Foos of Bar America", author: "Smith, James", year: 1921) 
  end

  context 'testing BibTeX capabilities' do 
    specify "the test file should have 42 records" do
      expect(@bibtex_bibliography.size).to eq(42)
    end

    specify "the first record has 4 fields populated" do
      expect(@bibtex_bibliography.first.fields.keys.size).to eq(4)
    end

    specify "title of first record is 'A Monograph of the Plecoptera or Stoneflies of America North of America'" do
      expect(@bibtex_bibliography.first.title).to eq('A Monograph of the Plecoptera or Stoneflies of America North of America')
    end

    specify "first record pubtype is 'book'" do
      expect(@bibtex_bibliography.first.type).to eq(:book)
    end

    specify "first record address is 'Lafayette, {IN}'" do
      expect(@bibtex_bibliography.first.address).to eq('Lafayette, {IN}')
    end

    specify "first record publisher is 'The Thomas Say Foundation'" do
      expect(@bibtex_bibliography.first.publisher).to eq('The Thomas Say Foundation')
    end

    specify "first record author is 'Needham, James G. and Claassen, Peter W.'" do
      expect(@bibtex_bibliography.first.author).to eq('Needham, James G. and Claassen, Peter W.')
    end

    specify "second record pubtype is 'article'" do
      expect(@bibtex_bibliography[1].type).to eq(:article)
    end

    specify "second record volume is '53'" do
      expect(@bibtex_bibliography[1].volume).to eq('53')
    end

    specify "second record issn is '1480-3283'" do
      expect(@bibtex_bibliography[1].issn).to eq('1480-3283')
    end

    specify "second record number is '2.'" do
      expect(@bibtex_bibliography[1].number).to eq('2')
    end

    specify "second record journal is 'Canadian Journal of Zoology'" do
      expect(@bibtex_bibliography[1].journal).to eq('Canadian Journal of Zoology')
    end

    specify "second record year is '1975'" do
      expect(@bibtex_bibliography[1].year).to eq('1975')
    end

    specify "second record pages is '132–153'" do
      expect(@bibtex_bibliography[1].pages).to eq('132–153')
    end

    specify "fourth record pubtype is 'incollection'" do
      expect(@bibtex_bibliography[3].type).to eq(:incollection)
    end

    specify "fourth record booktitle is 'International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies'" do
      expect(@bibtex_bibliography[3].booktitle).to eq('International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies')
    end

    specify "last record edition is 'Fourth'" do
      expect(@bibtex_bibliography[-1].edition).to eq('Fourth')
    end

    specify "last record url is 'http://www.nhm.ac.uk/hosted-sites/iczn/code/'" do
      expect(@bibtex_bibliography[-1].url).to eq('http://www.nhm.ac.uk/hosted-sites/iczn/code/')
    end

    specify "last record urldate is '2010-12-06'" do
      expect(@bibtex_bibliography[-1].urldate).to eq('2010-12-06')
    end

    specify "simple identity" do
      expect(@simple1).to eq(@simple2)
    end

    specify "simple complex entity" do
      expect(@entry1).to eq(@entry2)
    end
  end

  context "on save" do
    before do
      source.save
    end
  end

  context "instance methods" do
    before do
      @s = Source::Bibtex.new_from_bibtex(@entry1)
    end

    # TODO: fields doesn't include types
    specify "to_bibtex" do
      expect(@s.to_bibtex.fields).to eq(@entry1.fields)
    end

    specify "valid_bibtex?" do
      expect(@s.valid_bibtex?).to be_false
    end
  end

  context 'import from bibtex to Source::Bibtex' do
    specify "if we have an non-bibtex entry then #new_from_bibtex returns false" do
      expect(Source::Bibtex.new_from_bibtex(1)).to eq(false)
    end
  end

  pending "we should pretty print the source"
  pending "it should have identifiers pointing to their sources"

  context "if I have a zotero bibliography" do
    context "and I import it to TW" do
      context "when I update a record in zotero" do
        specify "then TW should be aware and notify me of discrepancies" do
        end
      end
    end
  end

  pending "it should compare their source fields to their persisted (TW) fields"

  specify "if we have a bibtex record convert it to a taxonworks source" do
    expect(Source::Bibtex.new_from_bibtex(@bibtex_bibliography[0]).valid?).to be(true)
  end

  context "relations / associations" do 
    context "roles" do
      pending "authors should be ordered"
      pending "editors should be ordered"
      pending "After save on new bibtex records, populate author/editor roles"
      pending "If authors/editors roles exist and bibtex author/editor is empty, populate bibtex author/editor"
      pending "On bibtex save, validate author vs. authors"
      pending "On bibtex save, validate editor vs. editors"
      pending "If updated a person, then update bibtex authors/editors"

      valid_person = FactoryGirl.create(:valid_person)
      %w{author editor}.each do |i|

        specify "#{i}s" do
          method = "#{i}s"
          expect(bibtex).to respond_to(method)
          expect(bibtex.send(method)).to eq([])
          expect(bibtex.save).to be_true
          expect(bibtex.send(method) << valid_person).to be_true
          expect(bibtex.save).to be_true
          expect(bibtex.send(method).first).to eq(valid_person)
        end
 
        specify "#{i}_roles" do
          method = "#{i}_roles"
          expect(bibtex).to respond_to(method)
          expect(bibtex.send(method)).to eq([])
          expect(bibtex.save).to be_true
          expect(bibtex.send("#{i}s") << valid_person).to be_true
          expect(bibtex.save).to be_true
          expect(bibtex.send(method).size).to eq(1)
        end
      end
    end
  end



 


  context "concerns" do
    it_behaves_like "identifiable"
    it_behaves_like "has_roles"
  end

end

