require 'rails_helper'

describe Source::Bibtex, type: :model, group: :sources do

  # TODO: shouldn't be needed ultimately
  after(:all) { Source.destroy_all }

  let(:bibtex) { FactoryBot.build(:source_bibtex) }

  let(:gem_bibtex_entry1) {
    BibTeX::Entry.new(bibtex_type: 'book', title: 'Foos of Bar America', author: 'Smith, James', year: 1921)
  }

  let(:gem_bibtex_entry2) {
    BibTeX::Entry.new(bibtex_type: 'book', title: 'Foos of Bar America', author: 'Smith, James', year: '1921')
  }

  let(:valid_gem_bibtex_book) {
    BibTeX::Entry.new(bibtex_type: 'book', title: 'Valid Bibtex of America', author: 'Smith, James')
  }

  let(:gem_bibtex_bibliography) {
    BibTeX.open(Rails.root + 'spec/files/bibtex/Taenionema.bib')
  }

  context '#clone' do
    before do
      bibtex.update!(title: 'This is verbatim', bibtex_type: :article)
    end

    specify 'labeled' do
      a = bibtex.clone
      expect(a.title).to eq("[CLONE of #{bibtex.id}] " + bibtex.title)
    end

    context '#roles' do
      let(:p1) { FactoryBot.create(:valid_person) }
      let(:p2) { FactoryBot.create(:valid_person) }
      let(:p3) { FactoryBot.create(:valid_person) }

      before do
        bibtex.roles << SourceAuthor.new(person: p1)
        bibtex.roles << SourceAuthor.new(person: p2)
        bibtex.roles << SourceEditor.new(person: p3)
      end

      specify 'are duplicated' do
        expect(bibtex.clone.roles.count).to eq(3)
      end
    end
  end

  context 'test bibtex-ruby gem capabilities we rely upon' do
    context 'using BibTeX bibliography' do
      specify 'the test file should have 42 records' do
        expect(gem_bibtex_bibliography.size).to eq(42)
      end

      specify 'the first record has 4 fields populated' do
        expect(gem_bibtex_bibliography.first.fields.keys.size).to eq(4)
      end

      specify "title of first record is 'A Monograph of the Plecoptera or Stoneflies of America North of America'" do
        expect(gem_bibtex_bibliography.first.title).to eq('A Monograph of the Plecoptera or Stoneflies of America North of America')
      end

      specify "first record pubtype is 'book'" do
        expect(gem_bibtex_bibliography.first.type).to eq(:book)
      end

      specify "first record address is 'Lafayette, {IN}'" do
        expect(gem_bibtex_bibliography.first.address).to eq('Lafayette, {IN}')
      end

      specify "first record publisher is 'The Thomas Say Foundation'" do
        expect(gem_bibtex_bibliography.first.publisher).to eq('The Thomas Say Foundation')
      end

      specify "first record author is 'Needham, James G. and Claassen, Peter W.'" do
        expect(gem_bibtex_bibliography.first.author).to eq('Needham, James G. and Claassen, Peter W.')
      end

      specify "first record author.last is 'Needham & Claassen'" do
        expect(gem_bibtex_bibliography.first.author[0].last).to eq('Needham')
      end

      specify "second record pubtype is 'article'" do
        expect(gem_bibtex_bibliography[1].type).to eq(:article)
      end

      specify "second record volume is '53'" do
        expect(gem_bibtex_bibliography[1].volume).to eq('53')
      end

      # TODO: the validator for ISSN identifiers has been perverted so as to *NOT* require the preamble 'ISSN ', even tough the ISSN spec is quite specific about its being there, because the Bibtex gem does not return it with the ISSN vslue as it should.
      specify "second record issn is '1480-3283'" do
        expect(gem_bibtex_bibliography[1].issn).to eq('1480-3283')
      end

      specify "second record number is '2.'" do
        expect(gem_bibtex_bibliography[1].number).to eq('2')
      end

      specify "second record journal is 'Canadian Journal of Zoology'" do
        expect(gem_bibtex_bibliography[1].journal).to eq('Canadian Journal of Zoology')
      end

      specify "second record year is '1975'" do
        expect(gem_bibtex_bibliography[1].year).to eq('1975')
      end

      specify "second record pages is '132–153'" do
        expect(gem_bibtex_bibliography[1].pages).to eq('132–153')
      end

      specify "fourth record pubtype is 'incollection'" do
        expect(gem_bibtex_bibliography[3].type).to eq(:incollection)
      end

      specify "fourth record booktitle is 'International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies'" do
        expect(gem_bibtex_bibliography[3].booktitle).to eq('International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies')
      end

      specify "last record edition is 'Fourth'" do
        expect(gem_bibtex_bibliography[-1].edition).to eq('Fourth')
      end

      specify "last record url is 'http://www.nhm.ac.uk/hosted-sites/iczn/code/'" do
        expect(gem_bibtex_bibliography[-1].url).to eq('http://www.nhm.ac.uk/hosted-sites/iczn/code/')
      end

      specify "last record urldate is '2010-12-06'" do
        expect(gem_bibtex_bibliography[-1].urldate).to eq('2010-12-06')
      end

      # WHY?
      specify 'simple identity' do
        expect(BibTeX::Entry.new()).to eq(BibTeX::Entry.new())
      end

      specify 'complex(?) entity identity ' do
        expect(gem_bibtex_entry1).to eq(gem_bibtex_entry2)
      end
    end

    context 'Should handle BibTeX formatting' do
      # BibTeX.parse doesn't handle math version so no sub or sup (e.g. 20<sup>th</sup>)
      specify 'Strings are output properly 1' do
        citation_string = %q(@Article{py03,
                                    title = "The \t{oo} annual meeting of {BibTeX}--users",
                                    author = "D\'{e}coret, X{\ae}vier and Victor, Paul {\'E}mile",
                                    editor = "Simon {"}the {saint"} Templar",
                                    publisher = "@ sign publishing",
                                    journal = "{Bib}TeX journal of \{funny\} ch\'{a}r{\aa}cter{\$}",
                                    year = {2003}})

        a = BibTeX::Bibliography.parse(citation_string, filter: :latex)
        entry = a.first
        src = Source::Bibtex.new_from_bibtex(entry)
        expect(src.save!).to be_truthy

        expect(src.cached_string('text')).to eq('Décoret, X. & Victor, P.É. (2003) The o͡o annual meeting of BibTeX–users S. "The Saint" Templar (Ed). BibTeX journal of {funny} cháråcter$.')
        expect(src.cached_string('html')).to eq('Décoret, X. &amp; Victor, P.É. (2003) The o͡o annual meeting of BibTeX–users S. "The Saint" Templar (Ed). <i>BibTeX journal of {funny} cháråcter$</i>.')

        # Note this was the original check (lower case editor in double quotes... seems like a massive edge case, so presently not allowing so that we can cleanup capitalization in general) 
        # expect(src.cached_string('text')).to eq('Décoret, X. & Victor, P.É. (2003) The o͡o annual meeting of BibTeX–users S. "the saint" Templar (Ed). BibTeX journal of {funny} cháråcter$.')
        # expect(src.cached_string('html')).to eq('Décoret, X. &amp; Victor, P.É. (2003) The o͡o annual meeting of BibTeX–users S. "the saint" Templar (Ed). <i>BibTeX journal of {funny} cháråcter$</i>.')
      end

      # input = 'Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution.'
      specify 'Strings are output properly 1' do
        citation_string = "@book{Brauer_1909,
            doi = {10.5962/bhl.title.1086},
            url = {http://dx.doi.org/10.5962/bhl.title.1086},
            year = 1909,
            publisher = {Smithsonian Institution},
            author = {August Brauer},
            title = {Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer.}
          }"
        a = BibTeX::Bibliography.parse(citation_string, filter: :latex)
        entry = a.first
        src = Source::Bibtex.new_from_bibtex(entry)
        expect(src.cached_string('text')).to start_with('Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution. Available from: http://dx.doi.org/10.5962/bhl.title.1086')
      end

      # input = 'Grubbs; Baumann & DeWalt. 2014. A review of the Nearctic genus Prostoia (Ricker) (Plecoptera: Nemouridae), with the description of a new species and a surprising range extension for P. hallasi Kondratieff and Kirchner. Zookeys. '
      specify 'Strings are output properly 3' do
        citation_string = "@article{Grubbs_2014,
            doi = {10.3897/zookeys.401.7299},
            url = {http://dx.doi.org/10.3897/zookeys.401.7299},
            year = 2014,
            month = {apr},
            publisher = {Pensoft Publishers},
            volume = {401},
            pages = {11--30},
            author = {Scott Grubbs and Richard Baumann and R. DeWalt and Tari Tweddale},
            title = {A review of the Nearctic genus Prostoia (Ricker) (Plecoptera, Nemouridae), with the description of a new species and a surprising range extension for P.~hallasi Kondratieff {\&} Kirchner},
            journal = {{ZooKeys}}
          }"
        a = BibTeX::Bibliography.parse(citation_string, filter: :latex)
        entry = a.first
        src = Source::Bibtex.new_from_bibtex(entry)
        expect(src.cached_string('html')).to eq('Grubbs, S., Baumann, R., DeWalt, R. &amp; Tweddale, T. (2014) A review of the Nearctic genus Prostoia (Ricker) (Plecoptera, Nemouridae), with the description of a new species and a surprising range extension for P. hallasi Kondratieff &amp; Kirchner. <i>ZooKeys</i> 401, 11–30.')
      end
    end

    # skip 'test export from a set of Source::Bibtex to a BibTeX::Bibliography'
  end

  context 'Ruby BibTeX related instance methods' do
    let(:s) { Source::Bibtex.new_from_bibtex(gem_bibtex_entry1) } 

    context 'to_bibtex' do
      specify 'basic features' do
        expect(s.bibtex_type.to_s).to eq(gem_bibtex_entry1.type.to_s)
        expect(s.to_bibtex.fields).to eq(gem_bibtex_entry1.fields)
      end

      context 'TW serial conversion' do
        let(:src) { FactoryBot.build(:soft_valid_bibtex_source_article, title: 'serial conversion') }
        let(:serial1) { FactoryBot.create(:valid_serial) } # create so serial1 has an ID

        specify 'serial gets converted properly to bibtex #journal' do
          src.soft_validate(:sv_missing_required_bibtex_fields)
          expect(src.soft_valid?).to be_truthy
          expect(src.journal).to eq('Journal of Test Articles')
          src.journal = nil
          src.soft_validate()
          expect(src.soft_validations.messages).to include 'This article is missing a journal name.'
          src.update!(serial: serial1)
          src.soft_validate(:sv_missing_required_bibtex_fields)
          expect(src.soft_valid?).to be_truthy
          bib = src.to_bibtex
          expect(bib.journal).to eq(serial1.name)
        end

        specify 'issn gets converted properly' do
          issn = FactoryBot.build(:issn_identifier)
          serial1.identifiers << issn
          expect(serial1.save).to be_truthy
          src.serial = serial1
          expect(src.save).to be_truthy
          src.soft_validate(:sv_missing_required_bibtex_fields)
          expect(src.soft_valid?).to be_truthy
          bib = src.to_bibtex
          expect(bib.issn).to eq(serial1.identifiers.where(type: 'Identifier::Global::Issn').first.identifier)
        end

        specify 'missing roles' do
          src.soft_validate(:missing_roles)
          expect(src.soft_validations.messages_on(:base)).to include('Author roles are not selected.')
          person = FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald')
          src.authors << person
          src.save
          src.soft_validate(:missing_roles)
          expect(src.soft_validations.messages_on(:base)).to_not include('Author roles are not selected.')
        end
      end

      context 'identifiers to bibtex' do
        let(:src) { FactoryBot.build(:soft_valid_bibtex_source_article) }

        specify 'url gets converted properly' do
          url = FactoryBot.build(:uri_identifier)
          src.identifiers << url
          expect(src.save).to be_truthy
          bib = src.to_bibtex
          expect(bib[:url]).to eq(src.identifiers.where(type: 'Identifier::Global::Uri').first.identifier)
        end

        specify 'isbn gets converted properly' do
          isbn = FactoryBot.build(:isbn_identifier)
          src.identifiers << isbn
          expect(src.save).to be_truthy
          bib = src.to_bibtex
          expect(bib[:isbn]).to eq(src.identifiers.where(type: 'Identifier::Global::Isbn').first.identifier)
        end

        specify 'doi gets converted properly' do
          doi = FactoryBot.build(:doi_identifier)
          src.identifiers << doi
          expect(src.save).to be_truthy
          bib = src.to_bibtex
          expect(bib[:doi]).to eq(src.identifiers.where(type: 'Identifier::Global::Doi').first.identifier)
        end
      end
    end

    context 'validate bibtex' do
      specify 'check that valid_bibtex? works (relies on BibTeX::Entry.valid? which is not currently working)' do
        expect(s.valid_bibtex?).to be_falsey # missing a publisher
      end

      specify 'soft_validate bibtex fields - get error messages' do
        s.soft_validate(:bibtex_fields)
        expect(s.soft_validations.messages_on(:publisher).empty?).to be_falsey
        expect(s.soft_validations.messages).to include 'Valid BibTeX requires a publisher to be associated with this source.'
      end

      specify 'make it valid' do
        s.publisher = 'Silly Books Inc'
        expect(s.valid_bibtex?).to be_truthy
      end
    end

    #  specify 'with a note in a BibTeX::Entry, convert it to a Source::Bibtex with an attached Note' do
    #    note                       = "This is a note.\n With multiple lines."
    #    valid_gem_bibtex_book.note = note
    #    s                          = Source::Bibtex.new_from_bibtex(valid_gem_bibtex_book)
    #    expect(s.notes.to_a.count).to eq(1)
    #    expect(s.notes.first.text).to eq(note + ' [Created on import from BibTeX.]')
    #    expect(s.save).to be_truthy
    #    expect(s.notes.first.id.nil?).to be_falsey
    #  end

    specify 'with an isbn in a BibTeX::Entry, convert it to an Identifier' do
      identifier                 = '1-84356-028-3'
      valid_gem_bibtex_book.isbn = identifier
      s                          = Source::Bibtex.new_from_bibtex(valid_gem_bibtex_book)
      expect(s.identifiers.to_a.size).to eq(1)
      expect(s.identifiers.first.identifier).to eq(identifier)
      expect(s.save).to be_truthy
      expect(s.identifiers.first.id.nil?).to be_falsey
      expect(s.isbn.to_s).to eq(identifier)
    end

    context 'with an issn in a BibTeX::Entry, convert it to an Identifier' do
      %w{2049-3630 1050-124x 1050-124X}.each do |n|
        specify "ISSN #{n}" do
          identifier                 = "ISSN #{n}"
          valid_gem_bibtex_book.issn = identifier
          s                          = Source::Bibtex.new_from_bibtex(valid_gem_bibtex_book)
          expect(s.identifiers.to_a.size).to eq(1)
          expect(s.identifiers.first.identifier).to eq(identifier)
          expect(s.save).to be_truthy
          expect(s.identifiers.first.id.nil?).to be_falsey
          expect(s.issn.to_s).to eq(identifier)
        end
      end
    end

    specify 'with a doi in a BibTeX::Entry, convert it to an Identifier' do
      # per http://www.doi.org/factsheets/DOIIdentifiers.html the following are all valid doi's
      #  Registrant using PII: doi:10.2345/S1384107697000225
      #  Registrant using SICI: doi:10.4567/0361-9230(1997)42:<OaEoSR>2.0.TX;2-B
      #  Registrant using internal scheme: doi:10.6789/JoesPaper56

      identifier = '10.2345/S1384107697000225'
      valid_gem_bibtex_book.doi = identifier
      s  = Source::Bibtex.new_from_bibtex(valid_gem_bibtex_book)
      expect(s.identifiers.to_a.size).to eq(1)
      expect(s.identifiers.first.identifier).to eq(identifier)
      expect(s.save).to be_truthy
      expect(s.identifiers.first.id.nil?).to be_falsey
      expect(s.doi.to_s).to eq(identifier)
    end
  end

  context 'validation' do

    specify 'title italics 1' do
      bibtex.title = '<i> foo'
      bibtex.valid?
      expect(bibtex.errors.include?(:title)).to be_truthy
    end

    specify 'title italics 2' do
      bibtex.title = '</i> foo'
      bibtex.valid?
      expect(bibtex.errors.include?(:title)).to be_truthy
    end

    specify 'title italics 3' do
      bibtex.title = '<i> asdfa</i> foo'
      bibtex.valid?
      expect(bibtex.errors.include?(:title)).to be_falsey
    end

    specify 'must have a valid bibtex_type' do
      local_src = FactoryBot.build(:valid_source_bibtex)
      expect(local_src.valid?).to be_truthy
      local_src.bibtex_type = 'test'
      expect(local_src.valid?).to be_falsey
      expect(local_src.errors.include?(:bibtex_type)).to be_truthy
      local_src.bibtex_type = nil
      expect(local_src.valid?).to be_falsey
      expect(local_src.errors.include?(:bibtex_type)).to be_truthy
    end

    specify 'must have one of the following fields: :author, :booktitle, :editor, :journal,
      :title, :year, :url, :stated_year' do
      error_message = 'Missing core data. A TaxonWorks source must have one of the following: author, editor, booktitle, title, url, journal, year, or stated year'
      local_src     = Source::Bibtex.new()
      expect(local_src.valid?).to be_falsey
      expect(local_src.errors.messages[:base]).to include error_message
      local_src.title = 'Test book'
      local_src.valid?
      expect(local_src.errors.full_messages.include?(error_message)).to be_falsey
    end

    context 'test date related fields' do
      let(:source_bibtex) { FactoryBot.build(:valid_source_bibtex) }

      # TODO: break to individual tests
      specify 'if present year, must be an integer an greater than 999 and no more than 2 years in the future' do
        error_msg = 'must be an integer greater than 999 and no more than 2 years in the future'
        source_bibtex.year = 'test'
        expect(source_bibtex.valid?).to be_falsey
        expect(source_bibtex.errors.messages[:year].include?(error_msg)).to be_truthy
        source_bibtex.year = 2000
        expect(source_bibtex.valid?).to be_truthy
        source_bibtex.soft_validate
        expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_truthy
        source_bibtex.year = 999
        expect(source_bibtex.valid?).to be_falsey
        expect(source_bibtex.errors.messages[:year].include?(error_msg)).to be_truthy
        source_bibtex.soft_validate
        expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_falsey
        expect(source_bibtex.soft_validations.messages).to include 'This year is prior to the 1700s.'
        source_bibtex.year = 1700
        expect(source_bibtex.valid?).to be_truthy
        source_bibtex.soft_validate
        expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_truthy
        source_bibtex.year = Time.now.year + 3
        expect(source_bibtex.valid?).to be_falsey
        expect(source_bibtex.errors.messages[:year].include?(error_msg)).to be_truthy
        source_bibtex.year = Time.now.year + 2
        expect(source_bibtex.valid?).to be_truthy
        source_bibtex.soft_validate
        expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_truthy
      end

      specify 'if month is set, there must be a year' do
        error_msg           = 'is required when month or stated_year is provided'
        source_bibtex.month = 'feb'
        expect(source_bibtex.valid?).to be_falsey
        expect(source_bibtex.errors.messages[:year].include?(error_msg)).to be_truthy
      end

      specify 'if stated_year is set, there must be a year' do
        # skip #TODO
      end

      context 'months' do
        before(:each) {
          source_bibtex.year = 1920
        }
        specify 'when passed a symbol, a string is returned' do
          source_bibtex.month = :jan
          expect(source_bibtex.month).to eq('jan')
        end
        specify 'when passed a string, a string is returned' do
          source_bibtex.month = 'jan'
          expect(source_bibtex.month).to eq('jan')
        end

        specify 'month must be in %w{jan feb mar ...}' do
          ::VALID_BIBTEX_MONTHS.each do |m|
            source_bibtex.month = m
            expect(source_bibtex.valid?).to be_truthy
          end
        end

        specify 'handles full month' do
          %w{january January}.each do |m|
            source_bibtex.month = m
            expect(source_bibtex.valid?).to be_truthy
            expect(source_bibtex.month).to eq('jan')
          end
        end

        specify 'handles integer month' do
          source_bibtex.month = 1
          expect(source_bibtex.valid?).to be_truthy
          expect(source_bibtex.month).to eq('jan')
        end

        specify 'generates error on integer month > 12' do
          source_bibtex.month = 45
          expect(source_bibtex.valid?).to be_falsey
          expect(source_bibtex.errors.include?(:month)).to be_truthy
        end

        specify 'handles roman numeral month' do
          source_bibtex.month = 'i'
          expect(source_bibtex.valid?).to be_truthy
          expect(source_bibtex.month).to eq('jan')
        end

        it 'generates error on invalid text month' do
          source_bibtex.month = 'foo'
          expect(source_bibtex.valid?).to be_falsey
          expect(source_bibtex.errors.include?(:month)).to be_truthy
        end
      end

      context 'day validation' do
        before(:each) {
          source_bibtex.year = 1945
        }
        specify 'if day is present there must be a month' do
          error_msg         = 'is required when day is provided'
          source_bibtex.day = 31
          expect(source_bibtex.valid?).to be_falsey
          expect(source_bibtex.errors.messages[:month].include?(error_msg)).to be_truthy
        end

        specify 'day, if present, must be valid for month' do
          source_bibtex.day   = 30
          source_bibtex.month = 'feb'
          expect(source_bibtex.valid?).to be_falsey
          expect(source_bibtex.errors.messages[:day].include?('30 is not a valid day for the month provided')).to be_truthy
          source_bibtex.day = 4
          expect(source_bibtex.valid?).to be_truthy
        end
      end
    end

    context 'on save set cached values - single author' do
      let(:l_src) { FactoryBot.create(:soft_valid_bibtex_source_article) }

      specify 'save src' do
        expect(l_src.save).to be_truthy
      end

      context 'after save' do
        before {
          l_src.save
        }

        specify 'src should have a cached value' do
          expect(l_src.cached.blank?).to be_falsey
        end

        specify 'which equals...(currently failing due to problems with citeproc)' do
          expect(l_src.cached).to eq('Person, T. (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')
        end

        specify 'cached author should be set' do
          expect(l_src.cached_author_string.blank?).to be_falsey
        end

        specify 'which equals...' do
          expect(l_src.cached_author_string).to eq('Person')
        end
      end
    end

    context 'before save set cached values - multiple authors' do
      let(:l_src) { FactoryBot.build(:src_mult_authors) }

      specify 'src should save' do
        expect(l_src.save).to be_truthy
      end

      context 'after save' do
        before {
          l_src.save
        }

        specify 'src should have a cached value' do
          expect(l_src.cached.blank?).to be_falsey
        end

        context 'correctly creates authority_name & cached_author_string' do
          let(:source_bibtex) { FactoryBot.build(:valid_source_bibtex) }

          context 'with author, but without authors' do
            specify 'single author' do
              source_bibtex.author = 'Thomas, D.'
              source_bibtex.save
              expect(source_bibtex.cached_author_string).to eq('Thomas')
              expect(source_bibtex.authority_name).to eq('Thomas')
            end

            specify 'multiple authors' do
              source_bibtex.author = 'Thomas, D. and Fowler, Chad and Hunt, Andy'
              source_bibtex.save!
              expect(source_bibtex.cached_author_string).to eq('Thomas, Fowler & Hunt')
              expect(source_bibtex.authority_name).to eq('Thomas, Fowler & Hunt')
            end

            specify 'valid Source::Bibtex but not valid BibTex::Entry' do
              l_src.year = nil
              l_src.soft_validate
              expect(l_src.soft_validations.messages_on(:year).empty?).to be_falsey
              expect(l_src.save).to be_truthy
              expect(l_src.cached_author_string).to eq('Thomas, Fowler & Hunt')
            end

            specify 'SourceAuthor role' do
              a = Person.parse_to_people('Dmitriev, D.A.').first
              a.save!
              SourceAuthor.create!(person_id: a.id, role_object: source_bibtex)
              expect(source_bibtex.cached_author_string).to eq('Dmitriev')
            end

            specify 'multiple updates' do
              a = Person.parse_to_people('Dmitriev, D.A.').first
              b = Person.parse_to_people('Yoder, M.J.').first
              a.save!
              b.save!
              source_bibtex.update!(roles_attributes: [{person_id: a.id, type: 'SourceAuthor'}])
              expect(source_bibtex.cached_author_string).to eq('Dmitriev')
              expect(source_bibtex.author).to eq('Dmitriev, D.A.')
              source_bibtex.update!(roles_attributes: [{id: source_bibtex.roles.first.id}, {person_id: b.id, type: 'SourceAuthor'}])

              expect(source_bibtex.reload.cached_author_string).to eq('Dmitriev & Yoder')
              expect(source_bibtex.reload.author).to eq('Dmitriev, D.A. and Yoder, M.J.')
            end
          end

          context 'without author or authors' do
            specify 'cached_author_string is nil' do
              source_bibtex.author = nil
              source_bibtex.save
              expect(source_bibtex.authority_name).to eq(nil)
              expect(source_bibtex.cached_author_string).to eq(nil)
            end
          end

        end

        specify 'cached string should be correct' do
          expect(l_src.cached).to eq('Thomas, D., Fowler, C. &amp; Hunt, A. (1920) Article with multiple authors. <i>Journal of Test Articles</i>.')
        end
      end
    end

    context '#url' do
      let(:src) { Source::Bibtex.new } 
      specify 'validation 1' do
        src.valid?
        expect(src.errors.messages[:url]).to be_empty
      end

      specify 'validation 2' do
        src.url = 'bad url'
        expect(src.valid?).to be_falsey
        expect(src.errors.messages[:url]).to_not be_empty
      end

      # TODO: needs only a single check, URL format should be
      # tested in a generic library
      %w{http://speciesfile.org https://duckduckgo.com ftp://test.edu}.each do |u|
        specify "#{u} is valid" do
          src.url = u 
          src.valid?
          expect(src.errors.messages[:url]).to be_empty
        end
      end

      context 'default values' do
        before { src.update!(bibtex_type: :article, title: 'Not a book', year: 1920) }

        specify 'are empty' do
          expect(src.reload.url).to be_falsey
        end

        specify 'not overwritten on save' do
          u = 'http://funstuff.com'
          src.update!(url: u)
          expect(src.reload.url).to eq(u)
        end
      end
    end
  end

  # sanity check for Housekeeping, which is also tested elsewhere
  context 'roles and housekeeping' do
    let(:bibtex) { Source::Bibtex.create(title: 'Roles', year: 1923, bibtex_type: 'book') }

    specify 'with << and an existing object' do
      expect(bibtex.roles.count).to eq(0)
      bibtex.authors << Person.new(last_name: 'Smith')
      expect(bibtex.save).to be_truthy

      expect(bibtex.authors.first.creator.nil?).to be_falsey
      expect(bibtex.authors.first.updater.nil?).to be_falsey

      expect(bibtex.roles.first.creator.nil?).to be_falsey
      expect(bibtex.roles.first.updater.nil?).to be_falsey
    end

    specify 'with .build and an existing person' do
      expect(bibtex.roles.count).to eq(0)
      p = Person.create(last_name: 'Smith')
      bibtex.author_roles.build(person: p)
      expect(bibtex.save).to be_truthy
      expect(bibtex.roles.first.creator.nil?).to be_falsey
      expect(bibtex.roles.first.updater.nil?).to be_falsey
      expect(bibtex.roles.first.project_id.nil?).to be_truthy # no project_id on author_roles
    end

    context 'with a new object' do
      let(:s) { Source::Bibtex.new(title: 'Roles II', year: 1924, bibtex_type: 'book') }
      # A setter solution that approximates nested_attributes_for (which can't be used on polymorphic through)
      specify 'with new and authors_to_create pattern' do
        s.authors_to_create = [{last_name: 'Yabbadabbadoo.'}]
        expect(s.save).to be_truthy
        expect(s.roles.count).to eq(1)
        expect(s.roles.first.creator.nil?).to be_falsey
        expect(s.roles.first.updater.nil?).to be_falsey
        expect(s.roles.first.project_id.nil?).to be_truthy

        expect(s.authors.first.creator.nil?).to be_falsey
        expect(s.authors.first.updater.nil?).to be_falsey
      end

      specify 'with new and authors_to_create pattern, no person created when parent is !valid' do
        expect(Person.count).to eq(0)
        s.authors_to_create = [{}]
        expect(s.save).to be_falsey
        expect(s.errors.include?(:base)).to be_truthy
        expect(Person.count).to eq(0)
      end
    end
  end

  context 'instance methods - ' do
    # before(:each) {
    #   # this is a TW Source::Bibtex - type article, with just a title
    #   source_bibtex = 
    # }


    let(:source_bibtex) { FactoryBot.build(:valid_source_bibtex) } 

    context 'with an existing instance of Source::Bibtex' do

      context '.create_related_people_and_roles()' do
        specify 'can not be run when .new_record?' do
          expect(source_bibtex.new_record?).to be_truthy
          expect(source_bibtex.valid?).to be_truthy
          source_bibtex.author = 'Smith, James'
          expect(source_bibtex.create_related_people_and_roles).to be_falsey
        end

        # NOTE: Be aware of possible translator roles, we don't handle this
        specify 'returns false when author.nil? && editor.nil?' do
          expect(source_bibtex.create_related_people_and_roles).to be_falsey
        end

        specify 'returns false when instance.valid? is false' do
          s = Source::Bibtex.new()
          expect(s.create_related_people_and_roles).to be_falsey
        end

        %w{author editor}.each do |a|
          context "creates people for #{a}s" do
            let(:source_bibtex) { FactoryBot.build(:valid_source_bibtex) }
            specify "single #{a}" do
              method = "#{a}s"
              source_bibtex.send("#{a}=".to_sym, 'Smith, Bill')
              source_bibtex.save
              expect(source_bibtex.send(method.to_sym).size).to eq(0)
              expect(source_bibtex.create_related_people_and_roles).to be_truthy
              source_bibtex.reload
              expect(source_bibtex.send(method.to_sym).size).to eq(1)
              #source_bibtex.reload
              expect(source_bibtex.send(method.to_sym).to_a.size).to eq(1)
              expect((source_bibtex.send(method.to_sym)).first.last_name).to eq('Smith')
              expect((source_bibtex.send(method.to_sym)).first.first_name).to eq('Bill')
            end

            specify "multiple #{a}s" do
              method = "#{a}s"

              source_bibtex.send("#{a}=".to_sym, 'Thomas, D. and Fowler, Chad and Hunt, Andy')
              expect(source_bibtex.save).to be_truthy
              expect(source_bibtex.send(method.to_sym).size).to eq(0)

              expect(Person.count).to eq(0)
              expect(source_bibtex.create_related_people_and_roles).to be_truthy
              expect(Person.count).to eq(3)

              source_bibtex.reload

              expect(source_bibtex.send(method.to_sym).to_a.size).to eq(3)
              expect(source_bibtex.send(method.to_sym).first.last_name).to eq('Thomas')
              expect(source_bibtex.send(method.to_sym).first.first_name).to eq('D.')
              author1_id = source_bibtex.send(method.to_sym).first.id
              author1    = Person.find(author1_id)
              expect(author1).to be_instance_of(Person::Unvetted)
              expect(Person.where(last_name: 'Thomas', first_name: 'D.').to_a.include?(author1)).to be_truthy

              expect(source_bibtex.send(method.to_sym).last.last_name).to eq('Hunt')
              expect(source_bibtex.send(method.to_sym).last.first_name).to eq('Andy')
            end
          end

          specify "#{a}s returns correctly ordered arrays" do
            method       = "#{a}s".to_sym
            method_roles = "#{a}_roles"
            source_bibtex.send("#{a}=".to_sym, 'Thomas, D. and Fowler, Chad and Hunt, Andy')
            expect(source_bibtex.save).to be_truthy
            expect(source_bibtex.send(method).size).to eq(0)
            expect(source_bibtex.create_related_people_and_roles).to be_truthy
            source_bibtex.reload
            source_bibtex.authors.reload
            source_bibtex.editors.reload
            expect(source_bibtex.send(method).to_a.size).to eq(3)

            a_id       = source_bibtex.send(method).first.id
            a_role_obj = source_bibtex.send(method_roles.to_sym)[0]
            expect(source_bibtex.send(method)[0].last_name).to eq('Thomas')
            expect(source_bibtex.send(method)[0].first_name).to eq('D.')
            expect(a_role_obj.position).to eq(1)
            expect(a_role_obj.person_id).to eq(a_id)

            a_id       = source_bibtex.send(method)[1].id
            a_role_obj = source_bibtex.send(method_roles.to_sym)[1]
            expect(source_bibtex.send(method)[1].last_name).to eq('Fowler')
            expect(source_bibtex.send(method)[1].first_name).to eq('Chad')
            expect(a_role_obj.position).to eq(2)
            expect(a_role_obj.person_id).to eq(a_id)

            a_id       = source_bibtex.send(method).last.id
            a_role_obj = source_bibtex.send(method_roles.to_sym)[2]
            expect(source_bibtex.send(method)[2].last_name).to eq('Hunt')
            expect(source_bibtex.send(method)[2].first_name).to eq('Andy')
            expect(a_role_obj.position).to eq(3)
            expect(a_role_obj.person_id).to eq(a_id)
          end
        end

        specify 'successfully creates a combination of authors & editors' do
          source_bibtex.author = 'Thomas, D. and Fowler, Chad and Hunt, Andy'
          source_bibtex.editor = 'Smith, Bill'
          source_bibtex.save
          expect(source_bibtex.authors.count).to eq(0)
          expect(source_bibtex.editors.count).to eq(0)
          expect(source_bibtex.create_related_people_and_roles).to be_truthy
          source_bibtex.reload

          expect(source_bibtex.authors.to_a.size).to eq(3)
          expect(source_bibtex.authors.first.last_name).to eq('Thomas')
          expect(source_bibtex.authors.first.first_name).to eq('D.')
          author1_id = source_bibtex.authors.first.id
          author1    = Person.find(author1_id)
          expect(author1).to be_instance_of(Person::Unvetted)
          expect(Person.where(last_name: 'Thomas', first_name: 'D.').to_a.include?(author1)).to be_truthy

          expect(source_bibtex.authors.last.last_name).to eq('Hunt')
          expect(source_bibtex.authors.last.first_name).to eq('Andy')

          expect(source_bibtex.editors.to_a.size).to eq(1)
          expect(source_bibtex.editors.first.last_name).to eq('Smith')
          expect(source_bibtex.editors.first.first_name).to eq('Bill')
        end

        context 'can not run on a source with existing roles' do
          %w{author editor}.each do |a|
            specify "can not be run when #{a} exists" do
              source_bibtex.send("#{a}=".to_sym, 'Smith, Bill and Jones, Jane')
              source_bibtex.save
              expect(source_bibtex.create_related_people_and_roles).to be_truthy
              source_bibtex.reload
              if a == 'author'
                expect(source_bibtex.valid? && source_bibtex.authors.count == 2).to be_truthy
                expect(source_bibtex.editors.count == 0).to be_truthy
              else # editor
                expect(source_bibtex.valid? && source_bibtex.editors.count == 2).to be_truthy
                expect(source_bibtex.authors.count == 0).to be_truthy
              end
              expect(source_bibtex.create_related_people_and_roles).to be_falsey #roles/people already exist
            end
          end
        end

        # TODO if the bibtex entry has a journal create the Serials
      end

      %w{author editor}.each do |a|
        context ".has_#{a}s? should evaluate both the #{a} attribute & roles" do
          let(:has_method) { "has_#{a}s?" }

          specify 'returns false if neither exist' do
            expect(source_bibtex.send(has_method)).to be_falsey
          end

          specify 'returns true if author attribute populated' do
            source_bibtex.send("#{a}=".to_sym, 'Smith, Bill')
            expect(source_bibtex.send(has_method)).to be_truthy
          end

          context 'saved and with .authors.count > 0 and (initially) !.author.nil?' do
            before {
              source_bibtex.save
              source_bibtex.send("#{a}=".to_sym, 'Smith, Bill')
              source_bibtex.create_related_people_and_roles
            }

            specify 'returns true when if !author.nil? AND .authors.count > 0' do
              source_bibtex.reload
              expect(source_bibtex.send(has_method)).to be_truthy
            end

            specify 'returns true if, subsequently, .author.nil?' do
              source_bibtex.send("#{a}=".to_sym, nil)
              source_bibtex.reload
              expect(source_bibtex.send(has_method)).to be_truthy
            end
          end
        end
      end

      specify 'test nomenclature_date generation' do
        source_bibtex.year = 1984
        expect(source_bibtex.save).to be_truthy
        source_bibtex.reload
        expect(source_bibtex.cached_nomenclature_date).to eq(Time.utc(1984, 12, 31))

        source_bibtex.month = 'feb'
        expect(source_bibtex.save).to be_truthy
        source_bibtex.reload
        expect(source_bibtex.cached_nomenclature_date).to eq(Time.utc(1984, 2, 29))

        source_bibtex.day = 12
        expect(source_bibtex.save).to be_truthy
        source_bibtex.reload
        expect(source_bibtex.cached_nomenclature_date).to eq(Time.utc(1984, 2, 12))

        # Times before before 1823, or after 2116 are handled differently.
        source_bibtex.year  = 1775
        source_bibtex.month = nil
        source_bibtex.day   = nil
        expect(source_bibtex.save).to be_truthy
        source_bibtex.reload
        expect(source_bibtex.cached_nomenclature_date).to eq(Time.utc(1775, 12, 31))
        source_bibtex.month = 'feb'
        expect(source_bibtex.save).to be_truthy
        source_bibtex.reload
        expect(source_bibtex.cached_nomenclature_date).to eq(Time.utc(1775, 2, 28))
        source_bibtex.day = 12
        expect(source_bibtex.save).to be_truthy
        source_bibtex.reload
        expect(source_bibtex.cached_nomenclature_date).to eq(Time.utc(1775, 2, 12))
      end

      specify 'sort an array of source by potentially_validating date' do
        Source.destroy_all
        source_bibtex.year = 2002 # source_bibtex has no date, title: 'article 1 just title'
        expect(source_bibtex.save).to be_truthy
        FactoryBot.create(:valid_bibtex_source_book_title_only) # 'valid book with just a title' : no date
        FactoryBot.create(:valid_thesis) # 'Bugs by Beth': june 1982
        FactoryBot.create(:valid_misc) # 'misc source': july 4 2010
        @sources = Source::Bibtex.order(id: :asc)
        expect(@sources.count).to eq(4)

        expect(@sources[0].title).to eq('article 1 just title')
        expect(@sources[1].title).to eq('valid book with just a title')
        expect(@sources[2].title).to eq('Bugs by Beth')
        expect(@sources[3].title).to eq('misc source')

        @source2 = Source::Bibtex.order_by_nomenclature_date
        expect(@source2.count).to eq(4)
        expect(@source2.map(&:title)).to eq(['Bugs by Beth', 'article 1 just title', 'misc source', 'valid book with just a title'])
      end
    end

    context 'attributes' do
      context 'Must facilitate letter annotations on year' do
        specify 'correctly generates year suffix from BibTeX entry' do
          bibtex_entry_year = BibTeX::Entry.new(type: :book, title: 'Foos of Bar America', author: 'Smith, James', year: '1921b')
          src               = Source::Bibtex.new_from_bibtex(bibtex_entry_year)
          expect(src.year.to_s).to eq('1921') # year is an int by default
          expect(src.year_suffix).to eq('b')
          expect(src.year_with_suffix).to eq('1921b')
        end

        specify 'correctly converts year suffix to BibTeX entry' do
          src = FactoryBot.create(:valid_source_bibtex)
          src[:year] = '1922'
          src[:year_suffix] = 'c'
          expect(src.year_with_suffix).to eq('1922c')
          bibtex_entry = src.to_bibtex
          expect(bibtex_entry[:year]).to eq('1922c')
        end
      end


    end

    context 'associations' do
      context 'roles' do
        let(:vp1) { Person.create!(last_name: 'Smith') }
        let(:vp2) { Person.create!(last_name: 'Adams', first_name: 'John', prefix: 'Von') }

        context 'check cached strings after update' do
          specify 'authors' do
            src1 = FactoryBot.create(:soft_valid_bibtex_source_article)
            expect(src1.cached).to eq('Person, T. (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')
            expect(src1.cached_author_string).to eq('Person')

            src1.authors << vp1
            expect(src1.reload.cached).to eq('Smith (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')
            expect(src1.cached_author_string).to eq('Smith')

            src1.authors << vp2
            expect(src1.reload.cached).to eq('Smith &amp; Von Adams, J. (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')
            expect(src1.cached_author_string).to eq('Smith & Von Adams')
          end

          specify 'editors' do
            src1 = FactoryBot.create(:src_editor)
            expect(src1.cached).to eq('Person, T. ed. (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')
            src1.editors << vp1
            expect(src1.reload.cached).to eq('Smith ed. (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')

            src1.editors << vp2
            expect(src1.reload.cached).to eq('Smith &amp; Von Adams, J. eds. (1700) I am a soft valid article. <i>Journal of Test Articles</i>.')
          end

          specify 'stated_year' do
            src1 = FactoryBot.create(:soft_valid_bibtex_source_article)
            src1.update(stated_year: '1699')
            expect(src1.cached).to eq('Person, T. (1700) I am a soft valid article. <i>Journal of Test Articles</i>. [1699]')
            src1.update(volume: '25')
            expect(src1.cached).to eq('Person, T. (1700) I am a soft valid article. <i>Journal of Test Articles</i> 25. [1699]')
          end

        end

        %w{author editor}.each do |i|
          specify "#{i}s" do
            method = "#{i}s"
            expect(bibtex).to respond_to(method)
            expect(bibtex.send(method)).to eq([])
            bibtex.title = 'valid record'
            bibtex.bibtex_type = 'book'
            expect(bibtex.save).to be_truthy 
            expect(bibtex.send(method) << vp1).to be_truthy 
            expect(bibtex.send(method).first.id).to eq(vp1.id)
          end

          specify "#{i}_roles" do
            method = "#{i}_roles"
            expect(bibtex).to respond_to(method)
            expect(bibtex.send(method)).to eq([])
            bibtex.title = 'valid record'
            bibtex.bibtex_type = 'book'
            expect(bibtex.save).to be_truthy
            expect(bibtex.send("#{i}s") << vp1).to be_truthy
            expect(bibtex.send(method).size).to eq(1)
          end
        end
      end
    end

    context 'matching through concerns' do
      let(:bib1) { FactoryBot.create(:valid_thesis) }
      let(:bib1a) {
        b = bib1.dup
        b.save!
        b
      }
      let(:bib2) { FactoryBot.create(:valid_thesis) }
      let(:bib3) { FactoryBot.create(:valid_misc, day: 5) }
      let(:bib4) { FactoryBot.create(:valid_misc, author: 'Anon, Test') }
      let(:trial) {
        Source::Bibtex.new(
          bibtex_type: bib3.bibtex_type,
          title: bib3.title,
          year: bib3.year,
          month: 'jul')
      }

      context '#identical' do
        specify 'full matching' do
          [bib1, bib2, bib3, bib4, bib1a]
          expect(bib1.identical.ids).to contain_exactly(bib2.id, bib1a.id)
        end
      end

      context '#similar' do
        specify 'full matching' do
          [bib1, bib2, bib3, bib4, bib1a]
          expect(trial.similar.ids).to contain_exactly(bib3.id, bib4.id)
        end
      end
    end
  end

  context 'class methods' do
    context '.new_from_bibtex' do
      let(:citation_string) { %q(@book{international_commission_on_zoological_nomenclature_international_1999,
                                    address = {London},
                                    edition = {Fourth},
                                    title = {International Code of Zoological Nomenclature},
                                    url = {http://www.nhm.ac.uk/hosted-sites/iczn/code/},
                                    urldate = {2010-12-06},
                                    publisher = {International Trust for Zoological Nomenclature},
                                    author = {International Commission on Zoological Nomenclature},
                                    type = {Journal Article},
                                    year = {1999}})
      }

      let(:bibtex_entry) { BibTeX::Bibliography.parse(citation_string).first }
      let(:a) { Source::Bibtex.new_from_bibtex(bibtex_entry) }

      before { a.save }

      specify 'import keys for non-recognized attributes' do
        expect(a.import_attributes.map(&:import_predicate)).to contain_exactly('urldate', 'type')
      end

      specify 'values for import predicates' do
        expect(a.import_attributes.map(&:value)).to contain_exactly('2010-12-06', 'Journal Article')
      end
    end

    context 'create_with_roles(BibTeX::Entry instance)' do
      specify 'creates author/editor roles with Person::Unvetted by default' do
        # skip
      end

      context 'parameters' do
        specify '{use_vetted_people: true} - uses exactly matching Person::Vetted found, otherwise creates new editors/authors' do
          # skip
        end
      end
    end

    context 'matching through concerns' do
      let(:bib1) { FactoryBot.create(:valid_thesis) }
      let(:bib1a) {
        b = bib1.dup
        b.save!
        b
      }
      let(:bib2) { FactoryBot.create(:valid_thesis) }
      let(:bib3) { FactoryBot.create(:valid_misc, day: 5) }
      let(:bib4) { FactoryBot.create(:valid_misc, author: 'Anon, Test') }
      let(:trial) {
        Source::Bibtex.new(bibtex_type: bib3.bibtex_type,
                           title:       bib3.title,
                           year:        bib3.year,
                           month:       'jul')
      }

      specify '#identical, full matchine' do
        [bib1, bib2, bib3, bib4, bib1a]
        expect(Source.identical(bib1.attributes).ids).to contain_exactly(bib2.id, bib1.id, bib1a.id)
      end

      specify '#similar, full matching' do
        [bib1, bib2, bib3, bib4, bib1a]
        expect(Source.similar(trial.attributes).ids).to contain_exactly(bib3.id, bib4.id)
      end
    end
  end

  context 'soft validations' do
    let(:source_bibtex) { FactoryBot.build(:soft_valid_bibtex_source_article) }

    specify 'missing authors 1' do
      source_bibtex.soft_validate(:recommended_fields)
      expect(source_bibtex.soft_validations.messages_on(:base).empty?).to be_truthy
    end

    specify 'missing authors 2' do
      source_bibtex.update(author: nil)
      source_bibtex.soft_validate(:recommended_fields)
      expect(source_bibtex.soft_validations.messages_on(:base).empty?).to be_falsey
      expect(source_bibtex.soft_validations.messages).to include('There is neither author, nor editor associated with this source.')
    end

    specify 'year is before 1700 (before nomenclature)' do
      source_bibtex.year = 1699
      expect(source_bibtex.valid?).to be_truthy
      source_bibtex.soft_validate()
      expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_falsey
      expect(source_bibtex.soft_validations.messages).to include 'This year is prior to the 1700s.'
      source_bibtex.year = 1700
      source_bibtex.save
      source_bibtex.soft_validate()
      expect(source_bibtex.soft_validations.messages_on(:year).empty?).to be_truthy
    end

    specify 'unpublished sources require a note' do
      source_bibtex.bibtex_type = 'unpublished'
      source_bibtex.soft_validate()
      expect(source_bibtex.soft_validations.messages_on(:note).empty?).to be_falsey
      expect(source_bibtex.soft_validations.messages).to include 'Valid BibTeX requires a note with an unpublished source.'
      source_bibtex.note = 'test note 1.'
      expect(source_bibtex.save).to be_truthy
      source_bibtex.soft_validate()
      expect(source_bibtex.soft_validations.messages_on(:note).empty?).to be_truthy
    end
  end

  context 'nested attributes' do
    let(:person1) { Person::Unvetted.create!(last_name: 'un') }
    let(:person2) { Person::Unvetted.create!(last_name: 'deux') }
    let(:person3) { Person::Unvetted.create!(last_name: 'trois') }
    let(:required_params) { {bibtex_type: 'article', title: 'Three Frenchmen'} }

    context 'with new source' do
      context 'creates new author role with existing person' do
        let(:params) { required_params.merge(
          author_roles_attributes: [{person_id: person1.id}]
        ) }
        let(:b) { Source::Bibtex.create!(params) }
        specify 'has one role' do
          expect(b.roles.reload.size).to eq(1)
        end
        specify 'has one author' do
          expect(b.authors.reload.size).to eq(1)
        end
      end

      context 'creates new author role and new person' do
        let(:params) { required_params.merge(
          author_roles_attributes: [{person_attributes: {last_name: 'nom'}}]
        ) }
        let(:b) { Source::Bibtex.create!(params) }
        specify 'has one role' do
          expect(b.roles.reload.size).to eq(1)
        end
        specify 'has one author' do
          expect(b.authors.reload.size).to eq(1)
        end
      end

      context 'authors (roles) are created in order' do
        let(:params) { required_params.merge(
          author_roles_attributes: [{person_id: person1.id}, {person_id: person2.id}, {person_id: person3.id}]
        ) }
        let(:b) { Source::Bibtex.create!(params) }
        specify 'author order is correct' do
          expect(b.authors.to_a).to eq([person1, person2, person3])
        end
      end
    end

    context 'with existing source' do
      let!(:b) { Source::Bibtex.create!(required_params) }
      let(:one_author_params) { {author_roles_attributes: [{person_id: person1.id}]} }
      let(:three_author_params) { {author_roles_attributes: [{person_id: person1.id}, {person_id: person2.id}, {person_id: person3.id}]
      } }

      context 'creates new author role with existing person' do
        let(:params) { required_params.merge(one_author_params) }
        specify 'update adds role' do
          expect(b.update!(params)).to be_truthy
          expect(b.roles.reload.size).to eq(1)
        end
      end

      context 'creates new author role and new person' do
        let(:params) { required_params.merge(
          author_roles_attributes: [{person_attributes: {last_name: 'nom'}}]
        ) }
        specify 'update adds role' do
          expect(b.update(params)).to be_truthy
          expect(b.roles.reload.size).to eq(1)
        end
      end

      context 'deletes existing author role' do
        before { b.update!(one_author_params) }
        context 'verify existing person is not deleted' do
          let(:params) { {
            author_roles_attributes: [{id: b.roles.first.id, _destroy: 1}]
          } }
          specify 'update destroys role' do
            expect(b.roles.reload.size).to eq(1)
            expect(b.update!(params)).to be_truthy
            expect(b.roles.reload.size).to eq(0)
          end
        end
      end

      context 'with three authors, deleting the middle author role maintains position' do
        before { b.update(three_author_params) }
        let(:params) {
          { author_roles_attributes: [{id: b.roles.second.id, _destroy: 1}]} 
        }

        specify 'three authors exist' do
          expect(b.authors.reload.size).to eq(3)
        end

        specify 'update updates position' do
          expect(b.authors.reload.count).to eq(3)
          expect(b.authority_name).to eq('Un, Deux & Trois')
          
          b.update(params)

          expect(b.authors.reload.count).to eq(2)
          expect(b.authority_name).to eq('Un & Trois')
          expect(b.roles.reload.first.position).to eq(1)
          expect(b.roles.last.position).to eq(2)
          expect(b.authors.last.last_name).to eq('Trois')
        end
      end

      context 'authors (roles) are rearranged according to specified position' do
        before { b.update!(three_author_params) }
        let(:params) { {
          author_roles_attributes: [{id: b.roles.second.id, position: 1}, {id: b.roles.third.id, position: 2}, {id: b.roles.first.id, position: 3}]
        } }

        specify 'update updates position' do
          expect(b.authority_name).to eq('Un, Deux & Trois')
          b.update!(params)
          expect(b.reload.authority_name).to eq('Deux, Trois & Un')
          expect(b.authors.collect{|a| a.last_name }).to eq(%w{Deux Trois Un})
        end
      end

    end
  end

end
