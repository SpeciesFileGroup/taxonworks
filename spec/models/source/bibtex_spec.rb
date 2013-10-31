require 'spec_helper'

describe Source::Bibtex do

  let(:bibtex) { Source::Bibtex.new }

  before(:all) do
    @gem_bibtex_bibliography = BibTeX.open(Rails.root + 'spec/files/Taenionema.bib')
    @simple1_gem_bibtex      = BibTeX::Entry.new()
    @simple2_gem_bibtex      = BibTeX::Entry.new()
    @gem_bibtex_entry1       = BibTeX::Entry.new(type: :book, title: 'Foos of Bar America', author: 'Smith, James', year: 1921)
    @gem_bibtex_entry2       = BibTeX::Entry.new(type: :book, title: 'Foos of Bar America', author: 'Smith, James', year: 1921)
    @valid_gem_bibtex_book   = BibTeX::Entry.new(type: :book, title: 'Valid Bibtex of America', author: 'Smith, James',
                                                 year: 1921, publisher: 'Test Books Inc.')
    @invalid_gem_bibtex_book = BibTeX::Entry.new(type: :book, title: 'InValid Bibtex of America', author: 'Smith, James',
                                                 year: 1921)
  end

  context 'testing BibTeX capabilities' do
    specify 'the test file should have 42 records' do
      expect(@gem_bibtex_bibliography.size).to eq(42)
    end

    specify 'the first record has 4 fields populated' do
      expect(@gem_bibtex_bibliography.first.fields.keys.size).to eq(4)
    end

    specify "title of first record is 'A Monograph of the Plecoptera or Stoneflies of America North of America'" do
      expect(@gem_bibtex_bibliography.first.title).to eq('A Monograph of the Plecoptera or Stoneflies of America North of America')
    end

    specify "first record pubtype is 'book'" do
      expect(@gem_bibtex_bibliography.first.type).to eq(:book)
    end

    specify "first record address is 'Lafayette, {IN}'" do
      expect(@gem_bibtex_bibliography.first.address).to eq('Lafayette, {IN}')
    end

    specify "first record publisher is 'The Thomas Say Foundation'" do
      expect(@gem_bibtex_bibliography.first.publisher).to eq('The Thomas Say Foundation')
    end

    specify "first record author is 'Needham, James G. and Claassen, Peter W.'" do
      expect(@gem_bibtex_bibliography.first.author).to eq('Needham, James G. and Claassen, Peter W.')
    end

    specify "second record pubtype is 'article'" do
      expect(@gem_bibtex_bibliography[1].type).to eq(:article)
    end

    specify "second record volume is '53'" do
      expect(@gem_bibtex_bibliography[1].volume).to eq('53')
    end

    specify "second record issn is '1480-3283'" do
      expect(@gem_bibtex_bibliography[1].issn).to eq('1480-3283')
    end

    specify "second record number is '2.'" do
      expect(@gem_bibtex_bibliography[1].number).to eq('2')
    end

    specify "second record journal is 'Canadian Journal of Zoology'" do
      expect(@gem_bibtex_bibliography[1].journal).to eq('Canadian Journal of Zoology')
    end

    specify "second record year is '1975'" do
      expect(@gem_bibtex_bibliography[1].year).to eq('1975')
    end

    specify "second record pages is '132–153'" do
      expect(@gem_bibtex_bibliography[1].pages).to eq('132–153')
    end

    specify "fourth record pubtype is 'incollection'" do
      expect(@gem_bibtex_bibliography[3].type).to eq(:incollection)
    end

    specify "fourth record booktitle is 'International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies'" do
      expect(@gem_bibtex_bibliography[3].booktitle).to eq('International Advances in the Ecology, Zoogeography, and Systematics of Mayflies and Stoneflies')
    end

    specify "last record edition is 'Fourth'" do
      expect(@gem_bibtex_bibliography[-1].edition).to eq('Fourth')
    end

    specify "last record url is 'http://www.nhm.ac.uk/hosted-sites/iczn/code/'" do
      expect(@gem_bibtex_bibliography[-1].url).to eq('http://www.nhm.ac.uk/hosted-sites/iczn/code/')
    end

    specify "last record urldate is '2010-12-06'" do
      expect(@gem_bibtex_bibliography[-1].urldate).to eq('2010-12-06')
    end

    specify "simple identity" do
      expect(@simple1_gem_bibtex).to eq(@simple2_gem_bibtex)
    end

    specify "simple complex entity" do
      expect(@gem_bibtex_entry1).to eq(@gem_bibtex_entry2)
    end
  end

  context 'if I have a zotero bibliography' do
    context 'and I import it to TW' do
      context 'when I update a record in zotero' do
        specify 'then TW should be aware and notify me of discrepancies' do
          pending 'not implemented yet'
        end
      end
    end
  end

  context 'Ruby BibTeX related instance methods' do
    before(:all) do
      @s = Source::Bibtex.new_from_bibtex(@gem_bibtex_entry1)
    end

    # TODO: fields doesn't include types
    specify 'to_bibtex' do
      expect(@s.to_bibtex.fields).to eq(@gem_bibtex_entry1.fields)
    end

    specify 'valid_bibtex?' do
      expect(@s.valid_bibtex?).to be_false
    end
  end

  context 'validation - a valid Source::Bibtex' do
    specify 'must have a valid bibtex_type' do
      local_src = FactoryGirl.create(:valid_bibtex_source)
      expect(local_src.valid?).to be_true
      local_src.bibtex_type = 'test'
      expect(local_src.valid?).to be_false
      expect(local_src.errors.include?(:bibtex_type)).to be_true
      local_src.bibtex_type = nil
      expect(local_src.valid?).to be_false
      expect(local_src.errors.include?(:bibtex_type)).to be_true
    end
    specify 'must have one of the following fields: :author, :booktitle, :editor, :journal,
      :title, :year, :URL, :stated_year' do
      error_message = 'no core data provided'
      local_src     = Source::Bibtex.new()
      expect(local_src.valid?).to be_false
      expect(local_src.errors.messages[:base].include?(error_message)).to be_true
      local_src.title = 'Test book'
      local_src.valid?
      expect(local_src.errors.full_messages.include?(error_message)).to be_false
    end
  end

  context 'instance methods - ' do
    context 'with an existing instance of Source::Bibtex' do
      before(:each) {
        # this is a TW Source::Bibtex - type article, with just a title
        @bibtex_source = FactoryGirl.build(:valid_bibtex_source)
        #@bibtex_book   = FactoryGirl.build(:valid_bibtex_source_book_title_only)
      }

      context 'create_related_people()' do
        specify 'can not be run when .new_record?' do
          expect(@bibtex_source.new_record?).to be_true
          expect(@bibtex_source.valid?).to be_true
          @bibtex_source.author = 'Smith, James'
          expect(@bibtex_source.create_related_people).to be_false
        end

        # NOTE: Be aware of possible translator roles, we don't handle this
        specify 'returns false when author.nil? && editor.nil?' do
          expect(@bibtex_source.create_related_people).to be_false
        end

        specify 'returns false when instance.valid? is false' do
          s = FactoryGirl.build(:bibtex_source)
          expect(s.create_related_people).to be_false
        end

        %w{author editor}.each do |a|
          context "creates people for #{a}s" do
            specify "single #{a}" do
              method = "#{a}s"
              @bibtex_source.send("#{a}=".to_sym, 'Smith, Bill')
              @bibtex_source.save
              expect(@bibtex_source.send(method.to_sym).size).to eq(0)
              expect(@bibtex_source.create_related_people).to be_true
              @bibtex_source.reload
              expect(@bibtex_source.send(method.to_sym).size).to eq(1)
              #@bibtex_source.reload
              expect(@bibtex_source.send(method.to_sym).to_a).to have(1).things
              expect((@bibtex_source.send(method.to_sym)).first.last_name).to eq('Smith')
              expect((@bibtex_source.send(method.to_sym)).first.first_name).to eq('Bill')
            end

            specify "multiple #{a}s" do
              method = "#{a}s"
              @bibtex_source.send("#{a}=".to_sym, 'Thomas, D. and Fowler, Chad and Hunt, Andy')
              @bibtex_source.save
              expect(@bibtex_source.send(method.to_sym).size).to eq(0)
              expect(@bibtex_source.create_related_people).to be_true
              @bibtex_source.reload

              expect(@bibtex_source.send(method.to_sym).to_a).to have(3).things
              expect(@bibtex_source.send(method.to_sym).first.last_name).to eq('Thomas')
              expect(@bibtex_source.send(method.to_sym).first.first_name).to eq('D.')
              author1_id = @bibtex_source.send(method.to_sym).first.id
              author1    = Person.find(author1_id)
              expect(author1).to be_instance_of(Person::Unvetted)
              expect(Person.where(last_name: 'Thomas', first_name: 'D.').to_a.include?(author1)).to be_true

              expect(@bibtex_source.send(method.to_sym).last.last_name).to eq('Hunt')
              expect(@bibtex_source.send(method.to_sym).last.first_name).to eq('Andy')
            end
          end

          specify "#{a}s returns correctly ordered arrays" do
            method = "#{a}s"
            method_roles = "#{a}_roles"
            @bibtex_source.send("#{a}=".to_sym, 'Thomas, D. and Fowler, Chad and Hunt, Andy')
            @bibtex_source.save
            expect(@bibtex_source.send(method.to_sym).size).to eq(0)
            expect(@bibtex_source.create_related_people).to be_true
            @bibtex_source.reload

            expect(@bibtex_source.send(method.to_sym).to_a).to have(3).things

            a_id = @bibtex_source.send(method.to_sym).first.id
            a_role_obj = @bibtex_source.send(method_roles.to_sym)[0]
            expect(@bibtex_source.send(method.to_sym)[0].last_name).to eq('Thomas')
            expect(@bibtex_source.send(method.to_sym)[0].first_name).to eq('D.')
            expect(a_role_obj.position).to eq(1)
            expect(a_role_obj.person_id).to eq(a_id)

            a_id = @bibtex_source.send(method.to_sym)[1].id
            a_role_obj = @bibtex_source.send(method_roles.to_sym)[1]
            expect(@bibtex_source.send(method.to_sym)[1].last_name).to eq('Fowler')
            expect(@bibtex_source.send(method.to_sym)[1].first_name).to eq('Chad')
            expect(a_role_obj.position).to eq(2)
            expect(a_role_obj.person_id).to eq(a_id)

            a_id = @bibtex_source.send(method.to_sym).last.id
            a_role_obj = @bibtex_source.send(method_roles.to_sym)[2]
            expect(@bibtex_source.send(method.to_sym)[2].last_name).to eq('Hunt')
            expect(@bibtex_source.send(method.to_sym)[2].first_name).to eq('Andy')
            expect(a_role_obj.position).to eq(3)
            expect(a_role_obj.person_id).to eq(a_id)
          end

        end

        specify 'successfully creats a combination of authors & editors' do
          @bibtex_source.author = 'Thomas, D. and Fowler, Chad and Hunt, Andy'
          @bibtex_source.save
          @bibtex_source.editor = 'Smith, Bill'
          expect(@bibtex_source.authors.size).to eq(0)
          expect(@bibtex_source.editors.size).to eq(0)
          expect(@bibtex_source.create_related_people).to be_true
          @bibtex_source.reload

          expect(@bibtex_source.authors.to_a).to have(3).things
          expect(@bibtex_source.authors.first.last_name).to eq('Thomas')
          expect(@bibtex_source.authors.first.first_name).to eq('D.')
          author1_id = @bibtex_source.authors.first.id
          author1    = Person.find(author1_id)
          expect(author1).to be_instance_of(Person::Unvetted)
          expect(Person.where(last_name: 'Thomas', first_name: 'D.').to_a.include?(author1)).to be_true

          expect(@bibtex_source.authors.last.last_name).to eq('Hunt')
          expect(@bibtex_source.authors.last.first_name).to eq('Andy')

          expect(@bibtex_source.editors.to_a).to have(1).things
          expect(@bibtex_source.editors.first.last_name).to eq('Smith')
          expect(@bibtex_source.editors.first.first_name).to eq('Bill')
        end

        context 'can not run on a source with existing roles' do
          %w{author editor}.each do |a|
            specify "can not be run when #{a} exists" do
              @bibtex_source.send("#{a}=".to_sym, 'Smith, Bill and Jones, Jane')
              @bibtex_source.save
              expect(@bibtex_source.create_related_people).to be_true #saves the roles
              @bibtex_source.reload
              if a == 'author'
                expect(@bibtex_source.valid? && @bibtex_source.authors.count == 2).to be_true
                expect(@bibtex_source.editors.count == 0).to be_true
              else # editor
                expect(@bibtex_source.valid? && @bibtex_source.editors.count == 2).to be_true
                expect(@bibtex_source.authors.count == 0).to be_true
              end
              expect(@bibtex_source.create_related_people).to be_false #roles/people already exist
            end
          end
        end

      end
    end

  end

  context 'associations' do
    context('roles') {
      #before do
      #  # create & save 3 people
      #  p1 = Person.new(last_name: 'Aus')
      #  p1.save
      #  p2 = Person.new(last_name: 'Bus')
      #  p2.save
      #  p3 = Person.new(last_name: 'Cus')
      #  p3.save
      #  # create 3 bibtex sources
      #  bs1 = Source::Bibtex.new(bibtex_type: 'article', title: 'a1b2c3', author: 'Aus, Bus, Cus')
      #  bs1.save
      #  bs2 = Source::Bibtex.new(bibtex_type: 'article', title: 'a3b1c2', author: 'Bus, Cus, Aus')
      #  bs2.save
      #  bs3 = Source::Bibtex.new(bibtex_type: 'article', title: 'a2b3c1', author: 'Cus, Aus, Bus')
      #  bs3.save
      #end

      specify 'After save on new bibtex records, populate author/editor roles' do
        # bs1 was saved in the "before", since the authors already exist in the db,
        # the roles should be automatially set?
        pending
      end

      specify 'bibtex.authors should be ordered by roles.position' do
        # assign author roles
        pending
      end

      pending 'editors should be ordered by roles.position'

      context 'on validation' do
        # Force the user to interact through authors first, then back save to author 
        pending 'invalidate if authors exist and author has changed, and no longer matches'

        # ditto for editors
        pending 'invalidate if editors exist and editor has changed, and no longer matches'
      end

      # TODO: This is a person-side test, should cascade update 
      # pending "If updated a person, then update bibtex authors/editors"

      valid_person = FactoryGirl.create(:valid_person)
      %w{author editor}.each do |i|
        specify "#{i}s" do
          method = "#{i}s"
          expect(bibtex).to respond_to(method)
          expect(bibtex.send(method)).to eq([])
          bibtex.title       = 'valid record'
          bibtex.bibtex_type = 'book'
          expect(bibtex.save).to be_true                         # save record to get an ID
          expect(bibtex.send(method) << valid_person).to be_true # assigns author but doesn't save role
          expect(bibtex.save).to be_true                         # saving bibtex also saves role
          expect(bibtex.send(method).first).to eq(valid_person)
        end

        specify "#{i}_roles" do
          method = "#{i}_roles"
          expect(bibtex).to respond_to(method)
          expect(bibtex.send(method)).to eq([])
          bibtex.title       = 'valid record'
          bibtex.bibtex_type = 'book'
          expect(bibtex.save).to be_true
          expect(bibtex.send("#{i}s") << valid_person).to be_true
          expect(bibtex.save).to be_true
          expect(bibtex.send(method).size).to eq(1)
        end
      end
    }
  end

  context('Beth') do

    context 'class methods' do #nothing implemented here
      specify 'bibtex_author_to_person' do
        pending 'write me'
      end

      context 'create_with_people (from BibTeX::Entry)' do
        context 'parameters' do
          specify 'bibtex: BibTex::Entry - passes the bibtex to import from' do
            pending
          end

          specify 'people: :create -  is default, creates new people for all roles' do
            pending
          end

          specify 'people: :match_exact - uses exactly matching Person::Unvetted when found, otherwise creates new editors/authors' do
            pending
          end
        end

        specify 'returns false if pre-save Source::Bibtex is !valid?' do
          pending
        end

        specify 'instantiates if BibTeX::Entry is not valid but Source::Bibtex is' do
          pending
        end

        specify 'instantiates without BibTeX::Entry.author or BibtexEntry.editor populated' do
          pending
        end

        specify 'instantiates with BibTeX::Entry.author' do
          pending
        end

        specify 'instantiates with BibTeX::Entry.editor' do
          pending
        end
      end
    end

  end

  context 'Hackathon requirements' do
    # these tests should be included somewhere above. Once completed move to the appropriate place.
    # when this is context is empty - delete it.
    pending 'Must allow letters after the year'

    pending 'Should be able to round trip data '
    #(e.g. import a BibTex file, then output a BibTex file and have them be the same.)

  end

  context 'concerns' do
    it_behaves_like "identifiable"
    it_behaves_like "has_roles"
  end
end

