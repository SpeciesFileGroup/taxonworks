require 'spec_helper'

describe Source::Bibtex do

  let(:bibtex) { FactoryGirl.build(:source_bibtex) }

  before(:each) do
    @gem_bibtex_bibliography = BibTeX.open(Rails.root + 'spec/files/bibtex/Taenionema.bib')
    @simple1_gem_bibtex = BibTeX::Entry.new()
    @simple2_gem_bibtex = BibTeX::Entry.new()
    @gem_bibtex_entry1 = BibTeX::Entry.new(type: :book, title: 'Foos of Bar America', author: 'Smith, James',
                                           year: 1921)
    @gem_bibtex_entry2 = BibTeX::Entry.new(type: :book, title: 'Foos of Bar America', author: 'Smith, James',
                                           year: 1921)
    @valid_gem_bibtex_book = BibTeX::Entry.new(type: :book, title: 'Valid Bibtex of America', author: 'Smith, James',
                                               year: 1921, publisher: 'Test Books Inc.')
    @invalid_gem_bibtex_book = BibTeX::Entry.new(type: :book, title: 'InValid Bibtex of America',
                                                 author: 'Smith, James', year: 1921)
  end

  context 'testing BibTeX bibliography capabilities' do
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

    specify 'simple identity' do
      expect(@simple1_gem_bibtex).to eq(@simple2_gem_bibtex)
    end

    specify 'simple complex entity' do
      expect(@gem_bibtex_entry1).to eq(@gem_bibtex_entry2)
    end

  end

  context 'Ruby BibTeX related instance methods' do
    before(:each) do
      @s = Source::Bibtex.new_from_bibtex(@gem_bibtex_entry1)
    end

    # TODO: fields doesn't include types
    specify 'to_bibtex' do
      expect(@s.to_bibtex.fields).to eq(@gem_bibtex_entry1.fields)
    end

    specify 'valid_bibtex?' do
      expect(@s.valid_bibtex?).to be_false
    end

    pending 'test conversion of BibTeX::Entry with note to Source::Bibtex'
    pending 'test conversion of BibTeX::Entry identifiers (URL, ISBN, etc) to Source::Bibtex with identifiers'
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
      local_src = Source::Bibtex.new()
      expect(local_src.valid?).to be_false
      expect(local_src.errors.messages[:base].include?(error_message)).to be_true
      local_src.title = 'Test book'
      local_src.valid?
      expect(local_src.errors.full_messages.include?(error_message)).to be_false
    end
  end

  context 'instance methods - ' do
    before(:each) {
      # this is a TW Source::Bibtex - type article, with just a title
      @source_bibtex = FactoryGirl.build(:valid_bibtex_source)
      #@bibtex_book   = FactoryGirl.build(:valid_bibtex_source_book_title_only)
    }
    context 'with an existing instance of Source::Bibtex' do

      # TODO: Update to create_roles for instance methods
      context 'create_related_people()' do
        specify 'can not be run when .new_record?' do
          expect(@source_bibtex.new_record?).to be_true
          expect(@source_bibtex.valid?).to be_true
          @source_bibtex.author = 'Smith, James'
          expect(@source_bibtex.create_related_people).to be_false
        end

        # NOTE: Be aware of possible translator roles, we don't handle this
        specify 'returns false when author.nil? && editor.nil?' do
          expect(@source_bibtex.create_related_people).to be_false
        end

        specify 'returns false when instance.valid? is false' do
          s = FactoryGirl.build(:source_bibtex)
          expect(s.create_related_people).to be_false
        end

        %w{author editor}.each do |a|
          context "creates people for #{a}s" do
            specify "single #{a}" do
              method = "#{a}s"
              @source_bibtex.send("#{a}=".to_sym, 'Smith, Bill')
              @source_bibtex.save
              expect(@source_bibtex.send(method.to_sym).size).to eq(0)
              expect(@source_bibtex.create_related_people).to be_true
              @source_bibtex.reload
              expect(@source_bibtex.send(method.to_sym).size).to eq(1)
              #@source_bibtex.reload
              expect(@source_bibtex.send(method.to_sym).to_a).to have(1).things
              expect((@source_bibtex.send(method.to_sym)).first.last_name).to eq('Smith')
              expect((@source_bibtex.send(method.to_sym)).first.first_name).to eq('Bill')
            end

            specify "multiple #{a}s" do
              method = "#{a}s"
              @source_bibtex.send("#{a}=".to_sym, 'Thomas, D. and Fowler, Chad and Hunt, Andy')
              @source_bibtex.save
              expect(@source_bibtex.send(method.to_sym).size).to eq(0)
              expect(@source_bibtex.create_related_people).to be_true
              @source_bibtex.reload

              expect(@source_bibtex.send(method.to_sym).to_a).to have(3).things
              expect(@source_bibtex.send(method.to_sym).first.last_name).to eq('Thomas')
              expect(@source_bibtex.send(method.to_sym).first.first_name).to eq('D.')
              author1_id = @source_bibtex.send(method.to_sym).first.id
              author1 = Person.find(author1_id)
              expect(author1).to be_instance_of(Person::Unvetted)
              expect(Person.where(last_name: 'Thomas', first_name: 'D.').to_a.include?(author1)).to be_true

              expect(@source_bibtex.send(method.to_sym).last.last_name).to eq('Hunt')
              expect(@source_bibtex.send(method.to_sym).last.first_name).to eq('Andy')
            end
          end

          specify "#{a}s returns correctly ordered arrays" do
            method = "#{a}s"
            method_roles = "#{a}_roles"
            @source_bibtex.send("#{a}=".to_sym, 'Thomas, D. and Fowler, Chad and Hunt, Andy')
            @source_bibtex.save
            expect(@source_bibtex.send(method.to_sym).size).to eq(0)
            expect(@source_bibtex.create_related_people).to be_true
            @source_bibtex.reload

            expect(@source_bibtex.send(method.to_sym).to_a).to have(3).things

            a_id = @source_bibtex.send(method.to_sym).first.id
            a_role_obj = @source_bibtex.send(method_roles.to_sym)[0]
            expect(@source_bibtex.send(method.to_sym)[0].last_name).to eq('Thomas')
            expect(@source_bibtex.send(method.to_sym)[0].first_name).to eq('D.')
            expect(a_role_obj.position).to eq(1)
            expect(a_role_obj.person_id).to eq(a_id)

            a_id = @source_bibtex.send(method.to_sym)[1].id
            a_role_obj = @source_bibtex.send(method_roles.to_sym)[1]
            expect(@source_bibtex.send(method.to_sym)[1].last_name).to eq('Fowler')
            expect(@source_bibtex.send(method.to_sym)[1].first_name).to eq('Chad')
            expect(a_role_obj.position).to eq(2)
            expect(a_role_obj.person_id).to eq(a_id)

            a_id = @source_bibtex.send(method.to_sym).last.id
            a_role_obj = @source_bibtex.send(method_roles.to_sym)[2]
            expect(@source_bibtex.send(method.to_sym)[2].last_name).to eq('Hunt')
            expect(@source_bibtex.send(method.to_sym)[2].first_name).to eq('Andy')
            expect(a_role_obj.position).to eq(3)
            expect(a_role_obj.person_id).to eq(a_id)
          end
        end

        specify 'successfully creates a combination of authors & editors' do
          @source_bibtex.author = 'Thomas, D. and Fowler, Chad and Hunt, Andy'
          @source_bibtex.editor = 'Smith, Bill'
          @source_bibtex.save
          expect(@source_bibtex.authors.size).to eq(0)
          expect(@source_bibtex.editors.size).to eq(0)
          expect(@source_bibtex.create_related_people).to be_true
          @source_bibtex.reload

          expect(@source_bibtex.authors.to_a).to have(3).things
          expect(@source_bibtex.authors.first.last_name).to eq('Thomas')
          expect(@source_bibtex.authors.first.first_name).to eq('D.')
          author1_id = @source_bibtex.authors.first.id
          author1 = Person.find(author1_id)
          expect(author1).to be_instance_of(Person::Unvetted)
          expect(Person.where(last_name: 'Thomas', first_name: 'D.').to_a.include?(author1)).to be_true

          expect(@source_bibtex.authors.last.last_name).to eq('Hunt')
          expect(@source_bibtex.authors.last.first_name).to eq('Andy')

          expect(@source_bibtex.editors.to_a).to have(1).things
          expect(@source_bibtex.editors.first.last_name).to eq('Smith')
          expect(@source_bibtex.editors.first.first_name).to eq('Bill')
        end

        context 'can not run on a source with existing roles' do
          %w{author editor}.each do |a|
            specify "can not be run when #{a} exists" do
              @source_bibtex.send("#{a}=".to_sym, 'Smith, Bill and Jones, Jane')
              @source_bibtex.save
              expect(@source_bibtex.create_related_people).to be_true #saves the roles
              @source_bibtex.reload
              if a == 'author'
                expect(@source_bibtex.valid? && @source_bibtex.authors.count == 2).to be_true
                expect(@source_bibtex.editors.count == 0).to be_true
              else # editor
                expect(@source_bibtex.valid? && @source_bibtex.editors.count == 2).to be_true
                expect(@source_bibtex.authors.count == 0).to be_true
              end
              expect(@source_bibtex.create_related_people).to be_false #roles/people already exist
            end
          end
        end

      end
    end

    %w{author editor}.each do |a|
      specify "has_#{a}s? should evaluate both the #{a} attribute & roles" do
        has_method = "has_#{a}s?"
        expect(@source_bibtex.send(has_method)).to be_false # returns false if neither exist
        @source_bibtex.send("#{a}=".to_sym, 'Smith, Bill')
        expect(@source_bibtex.send(has_method)).to be_true # returns true if has author attribute with a value
        @source_bibtex.save
        @source_bibtex.create_related_people
        @source_bibtex.reload
        expect(@source_bibtex.send(has_method)).to be_true # returns true if has both
        @source_bibtex.send("#{a}=".to_sym, '')
        expect(@source_bibtex.send(has_method)).to be_true # returns true if has only author roles
      end
    end

    specify 'test nomenclature_date generation' do
      @source_bibtex.year = '1984'
      expect(@source_bibtex.save).to be_true
      @source_bibtex.reload
      expect(@source_bibtex.nomenclature_date).to eq(Time.utc(1984,12,31))
      @source_bibtex.month = 'feb'
      expect(@source_bibtex.save).to be_true
      @source_bibtex.reload
      expect(@source_bibtex.nomenclature_date).to eq(Time.utc(1984,2,29))
      @source_bibtex.day = '12'
      expect(@source_bibtex.save).to be_true
      @source_bibtex.reload
      expect(@source_bibtex.nomenclature_date).to eq(Time.utc(1984,2,12))
      # Times before before 1823, after 2116 are handled differently.
      @source_bibtex.year = '1775'
      @source_bibtex.month = nil
      @source_bibtex.day = nil
      @source_bibtex.save
      @source_bibtex.reload
      expect(@source_bibtex.nomenclature_date).to eq(Time.utc(1775,12,31))
      @source_bibtex.month = 'feb'
      expect(@source_bibtex.save).to be_true
      @source_bibtex.reload
      expect(@source_bibtex.nomenclature_date).to eq(Time.utc(1775,2,28))
      @source_bibtex.day = '12'
      expect(@source_bibtex.save).to be_true
      @source_bibtex.reload
      expect(@source_bibtex.nomenclature_date).to eq(Time.utc(1775,2,12))
    end

    specify 'sort an array of source by nomenclatural date' do
      @source_bibtex.year = 2002 # source_bibtex has no date
      expect(@source_bibtex.save).to be_true
      @source_bibtex = FactoryGirl.build(:valid_bibtex_source_book_title_only)  # no date
      expect(@source_bibtex.save).to be_true
      @source_bibtex = FactoryGirl.build(:valid_thesis) # june 1982
      expect(@source_bibtex.save).to be_true
      @source_bibtex = FactoryGirl.build(:valid_misc)  # july 4 2010
      expect(@source_bibtex.save).to be_true
      @sources = Source::Bibtex.all
      expect(@sources).to have(4).things
      expect(@sources[0].title).to eq('article 1 just title')
      expect(@sources[1].title).to eq('valid book with just a title')
      expect(@sources[2].title).to eq('Bugs by Beth')
      expect(@sources[3].title).to eq('misc source')
      @source2 = @sources.order_by_nomenclature_date
      expect(@source2).to have(4).things
      expect(@source2[0].title).to eq('valid book with just a title')
      expect(@source2[1].title).to eq('Bugs by Beth')
      expect(@source2[2].title).to eq('article 1 just title')
      expect(@source2[3].title).to eq('misc source')
    end
  end

  context 'attributes' do
    pending 'Must facilitate letter annotations on year'
  end

  context 'associations' do
    context 'roles' do 
      specify 'after create/saved populate author/editor roles' do
        # bs1 was saved in the "before", since the authors already exist in the db,
        # the roles should be automatially set? (Yes)
        pending
      end

      specify 'after create/saved author/editor fields are cached versions of (="verbatim_" of TW) of authors/editors' do
        pending
      end

      specify 'if authors/editors are updated'  do
        pending
      end

      context 'on validation' do
        # Force the user to interact through authors first, then back save to author 
        pending 'invalidate if authors exist and author has changed, and no longer matches'

        # ditto for editors
        pending 'invalidate if editors exist and editor has changed, and no longer matches'
      end

      valid_person = FactoryGirl.create(:valid_person)
      %w{author editor}.each do |i|
        specify "#{i}s" do
          method = "#{i}s"
          expect(bibtex).to respond_to(method)
          expect(bibtex.send(method)).to eq([])
          bibtex.title = 'valid record'
          bibtex.bibtex_type = 'book'
          expect(bibtex.save).to be_true # save record to get an ID
          expect(bibtex.send(method) << valid_person).to be_true # assigns author but doesn't save role
          expect(bibtex.save).to be_true # saving bibtex also saves role
          expect(bibtex.send(method).first).to eq(valid_person)
        end

        specify "#{i}_roles" do
          method = "#{i}_roles"
          expect(bibtex).to respond_to(method)
          expect(bibtex.send(method)).to eq([])
          bibtex.title = 'valid record'
          bibtex.bibtex_type = 'book'
          expect(bibtex.save).to be_true
          expect(bibtex.send("#{i}s") << valid_person).to be_true
          expect(bibtex.save).to be_true
          expect(bibtex.send(method).size).to eq(1)
        end
      end
    end
  end


  context 'class methods' do
    # create_with_roles(bibtex_entry, opts = {})
    #    opts = {
    #      use_vetted_people: false
    #    }.merge!(opts)
    context 'create_with_roles(BibTeX::Entry instance)' do

      specify 'creates author/editor roles with Person::Unvetted by default' do
        pending
      end

      context 'parameters' do
        specify '{use_vetted_people: true} - uses exactly matching Person::Vetted found, otherwise creates new editors/authors' do
          pending
        end
      end
    end
  end

  context 'supporting libs' do
    context 'if I have a zotero bibliography' do
      context 'and I import it to TW' do
        context 'when I update a record in zotero' do
          specify 'then TW should be aware and notify me of discrepancies' do
            pending 'not implemented yet'
          end
        end
      end
    end

    context 'Hackathon requirements' do
      # TODO: code lib/bibtex
      pending 'Should be able to round trip data a whole file '
      #(e.g. import a BibTex file, then output a BibTex file and have them be the same.)
    end
  end

  context 'soft validations' do
    before(:each) {
      # this is a TW Source::Bibtex - type article, with just a title
      @source_bibtex = FactoryGirl.build(:valid_bibtex_source)
    }

    specify 'missing authors' do
      @source_bibtex.soft_validate
      expect(@source_bibtex.soft_valid?).to be_false
      expect(@source_bibtex.soft_validations.messages).to include 'There is no author associated with this source.'
    end
  end
  context('Beth') do
=begin
    notes/things to do:
      Document bibtex source using YardTags - se example in root\lib\soft_validation.rb
      Formatting -
        Rendering code will go in a helper
        Check out what formatting is provided by BibTex gem - do we additional formats?
      Set the cached fields in the bibtex records on save
      Has author role but no author field => bibtex should work
=end

    # from context 'roles'
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

  end

  context 'concerns' do
    it_behaves_like 'identifiable'
    it_behaves_like 'has_roles'
    # it_behaves_like 'notable'
  end

end
