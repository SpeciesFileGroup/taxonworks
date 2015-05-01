require 'rails_helper'

describe Person, :type => :model do

  let(:person) { FactoryGirl.build(:person) }
  let(:source_bibtex) {
    FactoryGirl.create(:valid_source_bibtex)
  }
  let(:human_source) {
    FactoryGirl.create(:valid_source_human)
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
      #expect(['Person::Vetted', 'Person::Unvetted'].include?(person.type)).to be_truthy
      expect(person.errors.include?(:type)).to be_falsey
      person.type='funny'
      person.valid?
      expect(person.errors.include?(:type)).to be_truthy #should have an error
    end
  end

  context 'instance methods' do
    specify '#bibtex_name formats correctly' do
      p = FactoryGirl.build(:source_person_jones) #  Mike Jones
      expect(p.bibtex_name).to eq('Jones, Mike')
      p = FactoryGirl.build(:source_person_prefix) #  John Von Adams
      expect(p.bibtex_name).to eq('Von Adams, John')
      p = FactoryGirl.build(:source_person_suffix) #  James Adams Jr.
      expect(p.bibtex_name).to eq('Adams, Jr., James')
      p = FactoryGirl.build(:source_person_both_ps) #  Janet Von Adams III
      expect(p.bibtex_name).to eq('Von Adams, III, Janet')
      p = FactoryGirl.build(:source_person_jones)
      p.first_name = ''             # Jones
      expect(p.bibtex_name).to eq('Jones')
      p.first_name = 'Sarah'
      p.last_name = ''
      expect(p.bibtex_name).to eq('Sarah')
    end
  end

  context 'class methods' do
    skip '.parser(name_string)'
    skip '.parse_to_people(name_srting)'
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
        expect(person).to respond_to(:type_material)
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
          expect(@person1.valid?).to be_truthy
        end

        specify 'camel cased last name and initials' do
          expect(@person2.valid?).to be_truthy
        end

        specify 'cased last initials and last name only' do
          expect(@person3.valid?).to be_truthy
        end

        specify 'last name, dashed first name' do
          expect(@person4.valid?).to be_truthy
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
      before(:each) {
        @vp = FactoryGirl.create(:valid_person)
      }

      specify '@vp is valid person' do
        expect(@vp.valid?).to be_truthy
      end

      specify 'is_author?' do
        expect(@vp).to respond_to(:is_author?)
        expect(@vp.is_author?).to be_falsey
        source_bibtex.authors << @vp
        source_bibtex.save!
        @vp.reload
        expect(@vp.is_author?).to be_truthy
      end
      specify 'is_editor?' do
        expect(@vp).to respond_to(:is_editor?)
        expect(@vp.is_editor?).to be_falsey
        source_bibtex.editors << @vp
        source_bibtex.save!
        @vp.reload
        expect(@vp.is_editor?).to be_truthy
      end
      specify 'is_source?' do
        expect(@vp).to respond_to(:is_source?)
        expect(@vp.is_source?).to be_falsey
        human_source.people << @vp
        human_source.save!
        @vp.reload
        expect(@vp.is_source?).to be_truthy
      end
      specify 'is_collector?' do
        expect(@vp).to respond_to(:is_collector?)
        expect(@vp.is_collector?).to be_falsey
        coll_event = FactoryGirl.create(:valid_collecting_event) 
        coll_event.collectors << @vp
        coll_event.save!
        @vp.reload
        expect(@vp.is_collector?).to be_truthy
      end
      specify 'is_determiner?' do
        expect(@vp).to respond_to(:is_determiner?)
        expect(@vp.is_determiner?).to be_falsey
        taxon_determination = FactoryGirl.create(:valid_taxon_determination)
        taxon_determination.determiner = @vp
        taxon_determination.save!
        @vp.reload # vp is getting set to 1, not @vp.id with this format
        expect(@vp.is_determiner?).to be_truthy
      end
      specify 'is_taxon_name_author?' do
        expect(@vp).to respond_to(:is_taxon_name_author?)
        expect(@vp.is_taxon_name_author?).to be_falsey
        taxon_name = FactoryGirl.create(:valid_protonym)
        taxon_name.taxon_name_authors << @vp
        taxon_name.save!
        @vp.reload
        expect(@vp.is_taxon_name_author?).to be_truthy
      end
      specify 'is_type_designator?' do
        expect(@vp).to respond_to(:is_type_designator?)
        expect(@vp.is_type_designator?).to be_falsey
        type_material = FactoryGirl.create(:valid_type_material)
        type_material.type_designators << @vp
        type_material.save!
        @vp.reload
        expect(@vp.is_type_designator?).to be_truthy
      end
    end
  end

  context 'cascading updates of sources' do
    skip "If person is updated then udpate their Bibtex::Author/Editor fields"
  end

  context 'concerns' do
    it_behaves_like 'alternate_values'
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'is_data'
    # TODO should it include SharedAcrossProjects?
  end

end
