require 'rails_helper' 
describe Person, type: :model, group: [:sources, :people] do

  let(:person) { Person.new }
  let(:source_bibtex) { FactoryBot.create(:valid_source_bibtex) }
  let(:human_source) { FactoryBot.create(:valid_source_human) }

  context 'validation' do
    before { person.valid? }

    specify 'last_name is required' do
      expect(person.errors[:last_name]).to be_present
    end

    specify 'type is required (set to \'Person::Unvetted\' when not provided)' do
      expect(person.type).to eq('Person::Unvetted')
    end

    specify 'validly_published type is either vetted or unvetted' do
      expect(person.errors.include?(:type)).to be_falsey
    end

    specify 'invalid_published type is either vetted or unvetted' do
      person.type = 'funny'
      person.valid?
      expect(person.errors.include?(:type)).to be_truthy
    end

    # ---- This series of validations are somewhat pointless
    specify 'initials and last name only' do
      person.update( first_name: 'January', last_name: 'Smith',
                    prefix: 'Dr.', suffix: 'III')
      expect(person.valid?).to be_truthy
    end

    specify 'camel cased last name and initials' do
      person.update( first_name: 'J.', last_name: 'McDonald' )
      expect(person.valid?).to be_truthy
    end

    specify 'cased last initials and last name only' do
      person.update( first_name: 'D. Keith McE.', last_name: 'Kevan')
      expect(person.valid?).to be_truthy
    end

    specify 'last name, dashed first name' do
      person.update( first_name: 'Ki-Su', last_name: 'Ahn')
      expect(person.valid?).to be_truthy
    end
    # ---- 

    context 'with roles' do
      before do
        person.update(last_name: 'Smith')
        source_bibtex.authors << person
      end

      specify 'destroy is prevented' do
        expect(person.destroy).to be_falsey
      end
    end
  end

  context 'select_optimized' do 
    before do
      person.update!(last_name: 'Smith', first_name: 'Jones')
      source_bibtex.authors << person
      source_bibtex.save
    end

    context 'no roles' do
      specify ':recent' do
        a = Person.select_optimized(Current.user_id, Current.project_id, 'SourceAuthor')
        expect(a[:recent].map(&:id)).to contain_exactly(person.id)
      end

      specify ':quick' do
        a = Person.select_optimized(Current.user_id, Current.project_id, 'SourceAuthor')
        expect(a[:quick].map(&:id)).to contain_exactly(person.id)
      end
    end

    context 'roles' do
      before do
        person.update!(created_at: 10.years.ago, updated_at: 10.years.ago)
      end

      context 'Collector' do
        let!(:ce){ CollectingEvent.create!(verbatim_locality: 'Ocean', collector_roles_attributes: [{person: person}]) }
        specify '.used_recently' do
          expect(Person.used_recently(Current.user_id,'Collector')).to contain_exactly(person.id)
        end

#        specify '.joins.used_recently.where()' do
#          expect(Person.joins(:roles).used_recently(Current.user_id, 'Collector').where(roles: {project_id: Current.project_id, updated_by_id: Current.user_id}).map(&:id)).to contain_exactly(person.id)
#        end

        specify ':recent' do
          a = Person.select_optimized(Current.user_id, Current.project_id, 'Collector')
          expect(a[:recent].map(&:id)).to contain_exactly(person.id)
        end

        specify ':quick' do
          a = Person.select_optimized(Current.user_id, Current.project_id, 'Collector')
          expect(a[:quick].map(&:id)).to contain_exactly(person.id)
        end
      end
 
     # Should be identical, sanity check 
      context 'Determiner' do
        let!(:td){ TaxonDetermination.create!(biological_collection_object: Specimen.create!, otu: Otu.create!(name: 'foo'), determiner_roles_attributes: [person: person]) }

#        specify '.used_recently' do
#          expect( Person.joins(:roles).where(roles: {project_id: Current.project_id, updated_by_id: Current.user_id} ).used_recently('Determiner').limit(10).map(&:id)).to contain_exactly(person.id)
#        end

        specify ':recent' do
          a = Person.select_optimized(Current.user_id, Current.project_id, 'Determiner')
          expect(a[:recent].map(&:id)).to contain_exactly(person.id)
        end

        specify ':quick' do
          a = Person.select_optimized(Current.user_id, Current.project_id, 'Determiner')
          expect(a[:quick].map(&:id)).to contain_exactly(person.id)
        end

      end

    end
  end


  context 'NameCase()' do
    specify '#1' do
      person.update(
        first_name: 'J.',
        last_name: 'SMITH',
      )
      expect(person.name).to eq('J. Smith')
    end

    specify '#2' do
      person.update(
        first_name: 'JONES',
        last_name: 'SMITH',
      )
      expect(person.name).to eq('Jones Smith')
    end

    specify '#3' do
      person.update(
        first_name: 'JONES',
        last_name: 'SMITH',
        prefix: 'VON',
        suffix: 'III'
      )
      expect(person.name).to eq('Jones von Smith III')
    end

    specify '#4' do
      person.update(
        first_name: 'JONES',
        last_name: 'SMITH',
        prefix: 'VON',
        suffix: 'III',
        no_namecase: true
      )
      expect(person.name).to eq('JONES VON SMITH III')
    end
  end

  specify '#name - initials, last name only' do
    person.update(
      first_name: 'J.',
      last_name: 'Smith',
      prefix: nil,
      suffix: nil
    )
    expect(person.name).to eq('J. Smith')
  end

  context 'used?' do
    before { person.update(last_name: 'Smith') }

    specify '#is_in_use? 1' do
      expect(person.is_in_use?).to be_falsey
    end

    specify '#is_in_use? 2' do
      c = FactoryBot.create(:valid_collecting_event)
      c.collectors << person
      expect(person.is_in_use?).to be_truthy
    end
  end

  context '#bibtex_name' do
    specify 'formats correctly 1' do
      expect(Person.new(last_name: 'Jones', first_name: 'Mike').bibtex_name).to eq('Jones, Mike')
    end

    specify 'formats correctly 2' do
      expect(Person.new(last_name: 'Jones').bibtex_name).to eq('Jones')
    end

    specify 'formats correctly 3' do
      expect(Person.new(first_name: 'Sarah').bibtex_name).to eq('Sarah')
    end

    specify 'formats correctly 4' do
      expect(Person.new(last_name: 'James', first_name: 'Adams', prefix: 'Von').bibtex_name).to eq('Von James, Adams')
    end

    specify 'formats correctly 5' do
      expect(Person.new(last_name: 'James', first_name: 'Adams', suffix: 'Jr.').bibtex_name).to eq('James, Jr., Adams')
    end

    specify 'formats correctly 6' do
      expect(Person.new(last_name: 'Adams', first_name: 'Janet', suffix: 'III', prefix: 'Von').bibtex_name)
        .to eq('Von Adams, III, Janet')
    end
  end

  # rubocop:disable Style/StringHashKeys
  specify '.parser' do
    expect(Person.parser('Smith, Sarah')).to eq([{'family' => 'Smith', 'given' => 'Sarah'}])
  end
  # rubocop:enable Style/StringHashKeys

  specify '.parse_to_people' do
    r = Person.parse_to_people('Smith, Sarah')
    expect(r.first.last_name).to eq('Smith')
  end

  context 'associations' do
    context 'has_many' do
      specify '#roles' do
        expect(person).to respond_to(:roles)
      end

      specify '#authored_sources' do
        expect(person).to respond_to(:authored_sources)
      end

      specify '#edited_sources' do
        expect(person).to respond_to(:edited_sources)
      end

      specify '#human_source' do
        expect(person).to respond_to(:human_sources)
      end

      specify '#collecting_events' do
        expect(person).to respond_to(:collecting_events)
      end

      specify '#taxon_determinations' do
        expect(person).to respond_to(:taxon_determinations) # determinations plural?
      end

      specify '#taxon_name_author' do
        expect(person).to respond_to(:authored_taxon_names)
      end

      specify '#georeferences' do
        expect(person).to respond_to(:georeferences)
      end
    end

    context 'usage and rendering' do
      let!(:person1) {
        p = FactoryBot.create(
          :person,
          first_name: 'January', last_name: 'Smith',
          prefix: 'Dr.', suffix: 'III')
        gr2.georeferencers << p
        p.data_attributes << da1
        p
      }

      let!(:person1a) {
        p = person1.dup
        p.save!
        p
      }

      let!(:person1b) {
        p = FactoryBot.create(
          :person,
          first_name: 'January', last_name: 'Smith',
          prefix: 'Dr.', suffix: 'III',
          year_born: 2000, year_died: 2015,
          year_active_start: 2012, year_active_end: 2015)
        tn2.taxon_name_authors << p
        tn1.taxon_name_authors << p
        gr1.georeferencers << p
        p.data_attributes << da2
        p
      }

      let(:person1c) {
        FactoryBot.create(
          :person,
          first_name: 'January', last_name: 'Smith',
          prefix: 'Dr.', suffix: 'III',
          year_born: 2000, year_died: 2015,
          year_active_start: 2012, year_active_end: 2015)
      }

      let(:person2) { FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald') }
      let(:person3) { FactoryBot.create(:person, first_name: 'D. Keith McE.', last_name: 'Kevan') }
      let(:person4) { FactoryBot.create(:person, first_name: 'Ki-Su', last_name: 'Ahn') }

      let(:tn1) { FactoryBot.create(:valid_taxon_name, name: 'Aonedidae') }
      let(:tn2) { FactoryBot.create(:valid_taxon_name, name: 'Atwodidae') }

      let(:cvt) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate,
                                    name: ' Honorific',
                                    definition: 'People:Honorific imported from INHS FileMaker database.') }
      let(:da1) { FactoryBot.create(:valid_data_attribute_internal_attribute,
                                    value:     'Dr.',
                                    predicate: cvt) }
      let(:da2) { FactoryBot.create(:valid_data_attribute_internal_attribute,
                                    value:     'Mr.',
                                    predicate: cvt) }

      let(:gr1) { FactoryBot.create(:valid_georeference) }
      let(:gr2) { FactoryBot.create(:valid_georeference) }


      context 'matching' do
        context 'instance methods' do

=begin
  What is the logic to declare one person 'identical' to another

  Easy tests:
    0) person.id: if this is the same as self.id, must be same record.
                  OR
    1) person.last_name == last_name
                AND
    2) person.first_name == first_name
                AND
      a) person.cached == cached

    3) person.prefix (subsumed by 'cached'?)
    4) person.suffix (subsumed by 'cached'?)

  A little harder:
    5) person.year_born (if both available)
    6) person.year_died (if both available)
    7) person.year_active_start (if both available)
    8) person.year_active_end (if both available)

  More complex:
    9) person.authored_taxon_names is same set as authored_taxon_names
      a) count is the same
                  AND
      b) taxon names match
=end


          context '#identical' do
            specify 'full matching' do
              # duplicate record
              [person1, person1a, person1b]
              expect(person1.identical.ids).to contain_exactly(person1a.id)
            end

            specify 'full match test life years' do
              # life year mismatch
              [person1, person1a, person1b]
              expect(person1.identical.ids).to contain_exactly(person1a.id)
            end

            specify 'full match test active years' do
              # active year mismatch
              [person1, person1a, person1b]
              person1.year_born = 2000
              person1.year_died = 2015
              person1.save!
              expect(person1.identical.count).to eq(0)
            end

            specify 'full match test active years only' do
              # life year mismatch, active year match
              [person1, person1a, person1b]
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(person1.identical.count).to eq(0)
            end

            specify 'full match all years' do
              # role count mismatch with no taxon name authorship
              [person1, person1a, person1b]
              person1.year_born         = 2000
              person1.year_died         = 2015
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(person1.identical.ids).to contain_exactly(person1b.id)
            end
          end

          context '#similar' do
            specify 'full matching' do
              # duplicate record
              [person1, person1a, person1b, person2, person3, person4]
              expect(person1.similar.ids).to contain_exactly(person1a.id, person1b.id)
            end

            specify 'full match test life years' do
              # life year mismatch
              [person1, person1a, person1b, person2, person3, person4]
              expect(person1.similar.ids).to contain_exactly(person1a.id, person1b.id)
            end

            specify 'full match test active years' do
              # active year mismatch
              [person1, person1a, person1b, person2, person3, person4]
              person1.year_born = 2000
              person1.year_died = 2015
              person1.save!
              expect(person1.similar.ids).to contain_exactly(person1b.id)
            end

            specify 'full match test active years only' do
              # life year mismatch, active year match
              [person1, person1a, person1b, person2, person3, person4]
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(person1.similar.ids).to contain_exactly(person1b.id)
            end

            specify 'full match all years' do
              # role count mismatch with no taxon name authorship
              [person1, person1a, person1b, person2, person3, person4]
              person1.year_born         = 2000
              person1.year_died         = 2015
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(person1.similar.ids).to contain_exactly(person1b.id)
            end

            specify 'initials only' do
              [person1, person1a, person1b, person2, person3, person4]
              person1.first_name = 'J.'
              person1.save!
              test_person = Person.new(first_name: 'J.')
              expect(test_person.similar.ids).to contain_exactly(person2.id, person1.id)
            end
          end
        end

        context 'class methods' do
          context '#identical' do
            specify 'full matching' do
              # duplicate record
              [person1, person1a, person1b]
              expect(Person.identical(person1.attributes).ids).to contain_exactly(person1.id, person1a.id)
            end

            specify 'full match test life years' do
              # life year mismatch
              [person1, person1a, person1b]
              expect(Person.identical(person1.attributes).ids).to contain_exactly(person1a.id, person1.id)
            end

            specify 'full match test active years' do
              # active year mismatch
              [person1, person1a, person1b]
              person1.year_born = 2000
              person1.year_died = 2015
              person1.save!
              expect(Person.identical(person1.attributes).ids).to contain_exactly(person1.id)
            end

            specify 'full match test active years only' do
              # life year mismatch, active year match
              [person1, person1a, person1b]
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(Person.identical(person1.attributes).ids).to contain_exactly(person1.id)
            end

            specify 'full match all years' do
              # role count mismatch with no taxon name authorship
              [person1, person1a, person1b]
              person1.year_born         = 2000
              person1.year_died         = 2015
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(Person.identical(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
            end

            specify 'initials only' do
              [person1, person1a, person1b, person2, person3, person4]
              person1.first_name = 'J.'
              person1.save!
              test_person = Person.new(first_name: 'J.')
              expect(Person.identical(test_person.attributes)).to be_empty
            end
          end

          context '#similar' do
            specify 'full matching' do
              # duplicate record
              [person1, person1a, person1b, person2, person3, person4]
              expect(Person.similar(person1.attributes).ids).to contain_exactly(person1a.id, person1b.id, person1.id)
            end

            specify 'full match test life years' do
              # life year mismatch
              [person1, person1a, person1b, person2, person3, person4]
              expect(Person.similar(person1.attributes).ids).to contain_exactly(person1a.id, person1b.id, person1.id)
            end

            specify 'full match test active years' do
              # active year mismatch
              [person1, person1a, person1b, person2, person3, person4]
              person1.year_born = 2000
              person1.year_died = 2015
              person1.save!
              expect(Person.similar(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
            end

            specify 'full match test active years only' do
              # life year mismatch, active year match
              [person1, person1a, person1b, person2, person3, person4]
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(Person.similar(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
            end

            specify 'full match all years' do
              # role count mismatch with no taxon name authorship
              [person1, person1a, person1b, person2, person3, person4]
              person1.year_born         = 2000
              person1.year_died         = 2015
              person1.year_active_start = 2012
              person1.year_active_end   = 2015
              person1.save!
              expect(Person.similar(person1.attributes).ids).to contain_exactly(person1b.id, person1.id)
            end

            specify 'initials only' do
              [person1, person1a, person1b, person2, person3, person4]
              person1.first_name = 'J.'
              person1.save!
              test_person = Person.new(first_name: 'J.')
              expect(Person.similar(test_person.attributes).ids).to contain_exactly(person2.id, person1.id)
            end
          end
        end
      end

      context 'roles' do
        let(:vp) { FactoryBot.create(:valid_person) }

        specify 'is_author?' do
          expect(vp.is_author?).to be_falsey
          source_bibtex.authors << vp
          expect(vp.is_author?).to be_truthy
        end

        specify 'is_editor?' do
          expect(vp.is_editor?).to be_falsey
          source_bibtex.editors << vp
          expect(vp.is_editor?).to be_truthy
        end

        specify 'is_source?' do
          expect(vp.is_source?).to be_falsey
          human_source.people << vp
          expect(vp.is_source?).to be_truthy
        end

        specify 'is_collector?' do
          expect(vp.is_collector?).to be_falsey
          coll_event = FactoryBot.create(:valid_collecting_event)
          coll_event.collectors << vp
          expect(vp.is_collector?).to be_truthy
        end

        specify 'is_determiner?' do
          expect(vp.is_determiner?).to be_falsey
          taxon_determination = FactoryBot.create(:valid_taxon_determination)
          taxon_determination.determiners << vp
          expect(vp.is_determiner?).to be_truthy
        end

        specify 'is_taxon_name_author?' do
          expect(vp.is_taxon_name_author?).to be_falsey
          taxon_name = FactoryBot.create(:valid_protonym)
          taxon_name.taxon_name_authors << vp
          expect(vp.is_taxon_name_author?).to be_truthy
        end
        
        specify 'is_georeferencer?' do
          expect(vp.is_georeferencer?).to be_falsey
          gr1.georeferencers << vp
          expect(vp.is_georeferencer?).to be_truthy
          expect(vp.georeferencer_roles.first.created_by_id).to be_truthy
          expect(vp.georeferencer_roles.first.updated_by_id).to be_truthy
        end
      end
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
end
