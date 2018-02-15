require 'rails_helper'

describe Person, type: :model do

  let(:person) { Person.new }
  
  let(:source_bibtex) {
    FactoryBot.create(:valid_source_bibtex)
  }
  let(:human_source) {
    FactoryBot.create(:valid_source_human)
  }

  context 'used?' do
    before do
      person.last_name = 'Smith'
      person.save!
    end

    specify '#is_in_use? 1' do
      expect(person.is_in_use?).to be_falsey
    end

    specify '#is_in_use? 2' do
      c = FactoryBot.create(:valid_collecting_event)
      c.collectors << person
      expect(person.is_in_use?).to be_truthy
    end
  end

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
      expect(person.errors.include?(:type)).to be_falsey
    end

    specify 'invalid_published type is either vetted or unvetted' do
      person.type='funny'
      person.valid?
      expect(person.errors.include?(:type)).to be_truthy 
    end
  end

  context 'years' do
    before { person.year_died = 1920 }
    specify 'died after birth' do
      person.year_born = 1930
      person.valid?
      expect(person.errors.include?(:year_born)).to be_truthy
    end

    specify 'not active after death - active start' do
      person.year_active_start = 1930
      person.valid?
      expect(person.errors.include?(:year_active_start)).to be_truthy
    end

    specify 'not active after death - active end' do
      person.year_active_end = 1930
      person.valid?
      expect(person.errors.include?(:year_active_end)).to be_truthy
    end

    specify 'not active before birth - active start' do
      person.year_born = 1920
      person.year_active_start = 1890
      person.valid?
      expect(person.errors.include?(:year_active_start)).to be_truthy
    end

    specify 'not active before birth - active end' do
      person.year_born = 1920
      person.year_active_end = 1890
      person.valid?
      expect(person.errors.include?(:year_active_end)).to be_truthy
    end

    specify 'lifespan' do
      person.year_born = 1900
      person.year_died = 2018
      person.valid?
      expect(person.errors.include?(:base)).to be_truthy
    end

  end

  context 'instance methods' do
    specify '#bibtex_name formats correctly 1' do
      expect(Person.new(last_name: 'Jones', first_name: 'Mike').bibtex_name).to eq('Jones, Mike')
    end
    
    specify '#bibtex_name formats correctly 2' do
      expect(Person.new(last_name: 'Jones').bibtex_name).to eq('Jones')
    end

    specify '#bibtex_name formats correctly 3' do
      expect(Person.new(first_name: 'Sarah').bibtex_name).to eq('Sarah')
    end

    specify '#bibtex_name formats correctly 4' do
      expect(Person.new(last_name: 'James', first_name: 'Adams', prefix: 'Von').bibtex_name).to eq('Von James, Adams')
    end

    specify '#bibtex_name formats correctly 5' do
      expect(Person.new(last_name: 'James', first_name: 'Adams', suffix: 'Jr.').bibtex_name).to eq('James, Jr., Adams')
    end

    specify '#bibtex_name formats correctly 6' do
      expect(Person.new(last_name: 'Adams', first_name: 'Janet', suffix: 'III', prefix: 'Von').bibtex_name).to eq('Von Adams, III, Janet')
    end
  end

  specify '.parser' do
    expect(Person.parser('Smith, Sarah')).to eq([{"family"=>"Smith", "given"=>"Sarah"}])
  end

  specify '.parse_to_people' do
     r = Person.parse_to_people('Smith, Sarah')
     expect(r.first.last_name).to eq('Smith')
  end

  context 'associations' do
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
        expect(person).to respond_to(:authored_taxon_names)
      end

      specify 'type_designations' do
        expect(person).to respond_to(:type_material)
      end

      specify 'georeferences' do
        expect(person).to respond_to(:georeferences)
      end
    end

    context 'usage and rendering' do
      let(:person1){ FactoryBot.build(:person, first_name: 'J.', last_name: 'Smith') }
      let(:person2){ FactoryBot.build(:person, first_name: 'J.', last_name: 'McDonald') }
      let(:person3){ FactoryBot.build(:person, first_name: 'D. Keith McE.', last_name: 'Kevan') }
      let(:person4){ FactoryBot.build(:person, first_name: 'Ki-Su', last_name: 'Ahn') }

      context 'usage' do
        specify 'initials and last name only' do
          expect(person1.valid?).to be_truthy
        end

        specify 'camel cased last name and initials' do
          expect(person2.valid?).to be_truthy
        end

        specify 'cased last initials and last name only' do
          expect(person3.valid?).to be_truthy
        end

        specify 'last name, dashed first name' do
          expect(person4.valid?).to be_truthy
        end

        context 'rendering' do
          specify 'initials, last name only' do
            expect(person1.name).to eq('J. Smith')
          end
        end
      end
    end

    # TODO: Fix.
    #  ... roles are not getting assigned creator/updater when << is used
    context 'roles' do
      let(:vp) { FactoryBot.create(:valid_person) }

      specify 'vp is valid person' do
        expect(vp.valid?).to be_truthy
      end

      specify 'is_author?' do
        expect(vp).to respond_to(:is_author?)
        expect(vp.is_author?).to be_falsey
        source_bibtex.authors << vp
        source_bibtex.save!
        vp.reload
        expect(vp.is_author?).to be_truthy
      end
      specify 'is_editor?' do
        expect(vp).to respond_to(:is_editor?)
        expect(vp.is_editor?).to be_falsey
        source_bibtex.editors << vp
        source_bibtex.save!
        vp.reload
        expect(vp.is_editor?).to be_truthy
      end
      specify 'is_source?' do
        expect(vp).to respond_to(:is_source?)
        expect(vp.is_source?).to be_falsey
        human_source.people << vp
        human_source.save!
        vp.reload
        expect(vp.is_source?).to be_truthy
      end
      specify 'is_collector?' do
        expect(vp).to respond_to(:is_collector?)
        expect(vp.is_collector?).to be_falsey
        coll_event = FactoryBot.create(:valid_collecting_event)
        coll_event.collectors << vp
        coll_event.save!
        vp.reload
        expect(vp.is_collector?).to be_truthy
      end
      specify 'is_determiner?' do
        expect(vp).to respond_to(:is_determiner?)
        expect(vp.is_determiner?).to be_falsey
        taxon_determination = FactoryBot.create(:valid_taxon_determination)
        taxon_determination.determiners << vp
        vp.reload # vp is getting set to 1, not vp.id with this format
        expect(vp.is_determiner?).to be_truthy
      end
      specify 'is_taxon_name_author?' do
        expect(vp).to respond_to(:is_taxon_name_author?)
        expect(vp.is_taxon_name_author?).to be_falsey
        taxon_name = FactoryBot.create(:valid_protonym)
        taxon_name.taxon_name_authors << vp
        taxon_name.save!
        vp.reload
        expect(vp.is_taxon_name_author?).to be_truthy
      end
      specify 'is_type_designator?' do
        expect(vp).to respond_to(:is_type_designator?)
        expect(vp.is_type_designator?).to be_falsey
        type_material = FactoryBot.create(:valid_type_material)
        type_material.type_designators << vp
        type_material.save!
        vp.reload
        expect(vp.is_type_designator?).to be_truthy
      end

      specify 'is_georeferencer?' do
        expect(vp).to respond_to(:is_georeferencer?)
        expect(vp.is_georeferencer?).to be_falsey
        georeference = FactoryBot.create(:valid_georeference)
        georeference.georeferencers << vp
        georeference.save!
        vp.reload
        expect(vp.is_georeferencer?).to be_truthy
        expect(vp.georeferencer_roles.first.created_by_id).to be_truthy
        expect(vp.georeferencer_roles.first.updated_by_id).to be_truthy
      end
    end
  end

  context 'cascading updates of sources' do
    # skip "If person is updated then udpate their Bibtex::Author/Editor fields"
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
