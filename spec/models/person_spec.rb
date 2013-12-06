require 'spec_helper'

describe Person do

  let(:person) { FactoryGirl.build(:person) }
  let(:bibtex_source) {
    FactoryGirl.create(:valid_bibtex_source)
  }
  let(:human_source) {
    FactoryGirl.create(:human_source)
  }
  #let(:coll_event) { CollectingEvent.new }

  context 'validation' do
    before do
      person.valid?
    end

    specify 'last_name is required' do
      expect(person.errors.keys).to include(:last_name)
    end

    specify "type is required (set to 'Person::Unvetted' when not provided)" do
      expect(person.type).to eq('Person::Unvetted')
    end

    specify 'validly_published type is either vetted or unvetted' do
      #expect(person.type).to eq('Person::Vetted' or 'Person::Unvetted')
      #expect(['Person::Vetted', 'Person::Unvetted'].include?(person.type)).to be_true
      expect(person.errors.include?(:type)).to be_false
      person.type='funny'
      person.valid?
      expect(person.errors.include?(:type)).to be_true #should have an error
    end
  end


  context 'associations' do

    #role orders: source_authors, source_editors, source_sources, collectors, (taxon_)determiners, taxon_name_authors, type_designators

    context 'has_many' do
      specify 'roles' do
        expect(person).to respond_to(:roles)
      end

      specify 'authored_sources' do
         expect(person).to respond_to(:authored_sources)
      end

      specify 'edited_sources' do
        expect(person).to respond_to(:edited_sources)
      end

      specify 'human_source' do
        expect(person).to respond_to(:human_sources)
      end

      specify 'collecting_events' do
        expect(person).to respond_to(:collecting_events)
      end

      specify 'taxon_determinations' do
        expect(person).to respond_to(:taxon_determinations)    # determinations plural?
      end

      specify 'taxon_name_author' do
        expect(person).to respond_to(:taxon_name_authors)
      end

      specify 'type_designations' do
        expect(person).to respond_to(:type_specimens)
      end
     end


    context 'usage and rendering' do

      let(:build_people) {
        @person1 = FactoryGirl.build(:person, first_name: 'J.', last_name: 'Smith')
        @person2 = FactoryGirl.build(:person, first_name: 'J.', last_name: 'McDonald')
        @person3 = FactoryGirl.build(:person, first_name: 'D. Keith McE.', last_name: 'Kevan')
        @person4 = FactoryGirl.build(:person, first_name: 'Ki-Su', last_name: 'Ahn')
      }

      before do
        build_people
      end

      context 'usage' do
        specify 'initials and last name only' do
          expect(@person1.valid?).to be_true
        end

        specify 'camel cased last name and initials' do
          expect(@person2.valid?).to be_true
        end

        specify 'cased last initials and last name only' do
          expect(@person3.valid?).to be_true
        end

        specify 'last name, dashed first name' do
          expect(@person4.valid?).to be_true
        end

        context 'rendering' do
          specify "initials, last name only" do
            expect(@person1.name).to eq("J. Smith")
          end
        end
      end
    end

    # TODO: Fix. 
    #  ... roles are not getting assigned creator/updater when << is used
    context 'roles' do
      before(:each) do
        @vp = FactoryGirl.create(:valid_person)
      end

      specify '@vp is valid person' do
        expect(@vp.valid?).to be_true
      end

      specify 'is_author?' do
        expect(@vp).to respond_to(:is_author?)
        expect(@vp.is_author?).to be_false
        bibtex_source.authors << @vp
        bibtex_source.save!
        @vp.reload
        expect(@vp.is_author?).to be_true
      end
      specify 'is_editor?' do
        expect(@vp).to respond_to(:is_editor?)
        expect(@vp.is_editor?).to be_false
        bibtex_source.editors << @vp
        bibtex_source.save!
        @vp.reload
        expect(@vp.is_editor?).to be_true
      end
      specify 'is_source?' do
        expect(@vp).to respond_to(:is_source?)
        expect(@vp.is_source?).to be_false
        human_source.people << @vp
        human_source.save!
        @vp.reload
        expect(@vp.is_source?).to be_true
      end
      specify 'is_collector?' do
        expect(@vp).to respond_to(:is_collector?)
        expect(@vp.is_collector?).to be_false
        coll_event = FactoryGirl.create(:valid_collecting_event) 
        coll_event.collectors << @vp
        coll_event.save!
        @vp.reload
        expect(@vp.is_collector?).to be_true
      end
      specify 'is_determiner?' do
        expect(@vp).to respond_to(:is_determiner?)
        expect(@vp.is_determiner?).to be_false
        taxon_determination = FactoryGirl.create(:valid_taxon_determination)
        taxon_determination.determiner = @vp
        taxon_determination.save!
        @vp.reload # vp is getting set to 1, not @vp.id with this format
        expect(@vp.is_determiner?).to be_true
      end
      specify 'is_taxon_name_author?' do
        expect(@vp).to respond_to(:is_taxon_name_author?)
        expect(@vp.is_taxon_name_author?).to be_false
        taxon_name = FactoryGirl.create(:valid_protonym)
        taxon_name.taxon_name_authors << @vp
        taxon_name.save!
        @vp.reload
        expect(@vp.is_taxon_name_author?).to be_true
      end
      specify 'is_type_designator?' do
        expect(@vp).to respond_to(:is_type_designator?)
        expect(@vp.is_type_designator?).to be_false
        type_specimen = FactoryGirl.create(:type_specimen)
        type_specimen.type_designators << @vp
        type_specimen.save!
        @vp.reload
        expect(@vp.is_type_designator?).to be_true
      end
    end
  end

  context 'cascading updates of sources' do
    pending "If person is updated then udpate their Bibtex::Author/Editor fields"
  end

end
