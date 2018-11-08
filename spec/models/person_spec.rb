require 'rails_helper' 
describe Person, type: :model do

  let(:person) { Person.new }

  let(:source_bibtex) {
    FactoryBot.create(:valid_source_bibtex)
  }
  let(:human_source) {
    FactoryBot.create(:valid_source_human)
  }
  let(:gr1) { FactoryBot.create(:valid_georeference) }
  let(:gr2) { FactoryBot.create(:valid_georeference) }

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

    context 'as author/editor' do
      before do 
        person.last_name = 'Smith'
        person.save!
      end

      specify 'active after death as editor - active start' do
        source_bibtex.editors << person
        person.reload
        person.year_active_start = 1930
        person.valid?
        expect(person.errors.include?(:year_active_start)).to be_falsey
      end

      specify 'active after death as author - active start' do
        source_bibtex.authors << person
        person.reload
        person.year_active_start = 1930
        person.valid?
        expect(person.errors.include?(:year_active_start)).to be_falsey
      end
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
        expect(person).to respond_to(:taxon_determinations) # determinations plural?
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
      let!(:person1) {
        p = FactoryBot.create(:person,
                              first_name: 'January', last_name: 'Smith',
                              prefix:     'Dr.', suffix: 'III')
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
        p = FactoryBot.create(:person,
                              first_name: 'January', last_name: 'Smith',
                              prefix:     'Dr.', suffix: 'III',
                              # type:              'Person::Unvetted',
                              year_born:         2000, year_died: 2015,
                              year_active_start: 2012, year_active_end: 2015)
      tn2.taxon_name_authors << p
      tn1.taxon_name_authors << p
      gr1.georeferencers << p
      p.data_attributes << da2
      p
      }
      let(:person1c) {
        p = FactoryBot.create(:person,
                              first_name: 'January', last_name: 'Smith',
                              prefix:     'Dr.', suffix: 'III',
                              # type:              'Person::Unvetted',
                              year_born:         2000, year_died: 2015,
                              year_active_start: 2012, year_active_end: 2015)
      # additional attributes not replicated yet
      p
      }
      let(:person2) { FactoryBot.create(:person, first_name: 'J.', last_name: 'McDonald') }
      let(:person3) { FactoryBot.create(:person, first_name: 'D. Keith McE.', last_name: 'Kevan') }
      let(:person4) { FactoryBot.create(:person, first_name: 'Ki-Su', last_name: 'Ahn') }

      let(:tn1) { FactoryBot.create(:valid_taxon_name, name: 'Aonedidae') }
      let(:tn2) { FactoryBot.create(:valid_taxon_name, name: 'Atwodidae') }

      let(:cvt) { FactoryBot.create(:valid_controlled_vocabulary_term_predicate,
                                    name:       ' Honorific',
                                    definition: 'People:Honorific imported from INHS FileMaker database.') }
      let(:da1) { FactoryBot.create(:valid_data_attribute_internal_attribute,
                                    value:     'Dr.',
                                    predicate: cvt) }
      let(:da2) { FactoryBot.create(:valid_data_attribute_internal_attribute,
                                    value:     'Mr.',
                                    predicate: cvt) }
      let(:id1) { FactoryBot.create(:valid_identifier) }
      let(:no1) { FactoryBot.create(:valid_note) }
      let(:av1) { FactoryBot.create(:valid_alternate_value,
                                    value:                            'Jan',
                                    alternate_value_object_attribute: 'first_name',
                                    alternate_value_object:           person1b) }
      let(:av2) { FactoryBot.create(:valid_alternate_value,
                                    value:                            'Janco',
                                    alternate_value_object_attribute: 'first_name',
                                    alternate_value_object:           person1) }

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
            person1.first_name = 'J.'
            person1.prefix     = nil
            person1.suffix     = nil
            person1.save!
            expect(person1.name).to eq('J. Smith')
          end
        end
      end

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

      context 'merging' do
        context 'two persons become one' do
          context 'years are combined' do
            context 'fills target year' do
              specify 'if empty' do
                person1.merge_with(person1b.id)
                expect(person1.year_born).to eq(person1b.year_born)
              end

              specify 'if source start earlier' do
                person1.year_active_start = person1b.year_active_start + 1
                person1.save!
                person1.merge_with(person1b.id)
                expect(person1.year_active_start).to eq(person1b.year_active_start)
              end

              specify 'if source start later' do
                person1.year_active_start = person1b.year_active_start - 1
                person1.save!
                pre = person1.year_active_start
                person1.merge_with(person1b.id)
                expect(person1.year_active_start).to eq(pre)
              end

              specify 'if source end later' do
                person1.year_active_end = person1b.year_active_end - 1
                person1.save!
                person1.merge_with(person1b.id)
                expect(person1.year_active_end).to eq(person1b.year_active_end)
              end

              specify 'if source end earlier' do
                person1.year_active_end = person1b.year_active_end + 1
                person1.save!
                pre = person1.year_active_end
                person1.merge_with(person1b.id)
                expect(person1.year_active_end).to eq(pre)
              end
            end
          end

          context 'prefix is combined' do
            specify 'source is nil' do
              person1.prefix = nil
              person1.save!
              person1.merge_with(person1b.id)
              expect(person1.prefix).to eq(person1b.prefix)
            end

            specify 'source is blank' do
              person1.prefix = ''
              person1.save!
              person1.merge_with(person1b.id)
              expect(person1.prefix).to eq(person1b.prefix)
            end

            specify 'source is whitespace' do
              person1.prefix = ' '
              person1.save!
              person1.merge_with(person1b.id)
              expect(person1.prefix).to eq(person1b.prefix)
            end
          end

          context 'suffix is combined' do
            specify 'source is nil' do
              person1.suffix = nil
              person1.save!
              person1.merge_with(person1b.id)
              expect(person1.suffix).to eq(person1b.suffix)
            end

            specify 'source is blank' do
              person1.suffix = ''
              person1.save!
              person1.merge_with(person1b.id)
              expect(person1.suffix).to eq(person1b.suffix)
            end

            specify 'source is whitespace' do
              person1.suffix = ' '
              person1.save!
              person1.merge_with(person1b.id)
              expect(person1.suffix).to eq(person1b.suffix)
            end
          end

          specify 'roles are combined' do
            person1.merge_with(person1b.id)
            expect(person1.roles.map(&:type)).to include('TaxonNameAuthor', 'Georeferencer')
          end

          specify 'data_attributes are combined' do
            person1.merge_with(person1b.id)
            person1.reload # TODO: Wondering why this 'reload' is requied?
            expect(person1.data_attributes.map(&:value)).to include('Mr.', 'Dr.')
          end

          specify 'identifiers' do
            person1b.identifiers << id1
            person1b.save!
            person1.merge_with(person1b.id)
            expect(person1.identifiers).to include(id1)
          end

          specify 'notes' do
            person1b.notes << no1
            person1b.save!
            person1.merge_with(person1b.id)
            expect(person1.notes).to include(no1)
          end

          context 'alternate values' do
            specify 'creating' do
              av1
              person1.merge_with(person1b.id)
              expect(person1.alternate_values).to include(av1)
            end

            context 'different names' do
              specify 'first name' do
                person1b.first_name = 'Janco'
                person1b.save!
                person1.merge_with(person1b.id)
                expect(person1.alternate_values.last.value).to include(person1b.first_name)
              end

              specify 'first name with matching alternate value' do
                av2 # person1.first_name = January, person1.altername_value.first.value = Janco
                person1b.first_name = 'Janco'
                person1b.save!
                # this will try to add Janco as an alternate_value, but skip
                person1.merge_with(person1b.id)
                expect(person1.alternate_values.count).to eq(1)
              end

              specify 'last name' do
                person1b.last_name = 'Smyth'
                person1b.save!
                person1.merge_with(person1b.id)
                expect(person1.alternate_values.last.value).to include(person1b.last_name)
              end
            end
          end

          context 'names' do
            context 'r_person' do
              context 'truthyness' do
                specify 'nil first name' do
                  person1b.first_name = nil
                  person1b.save!
                  trial = person1.merge_with(person1b.id)
                  expect(trial).to be_truthy
                end
              end

              context 'success' do
                specify 'nil first name' do
                  person1b.first_name = nil
                  person1b.save!
                  bfr = person1.first_name
                  person1.merge_with(person1b.id)
                  expect(person1.first_name).to eq(bfr)
                end
              end
            end

            context 'l_person' do
              context 'truthyness' do
                specify 'nil first name' do
                  person1.first_name = nil
                  person1.save!
                  trial = person1.merge_with(person1b.id)
                  expect(trial).to be_truthy
                end
              end

              context 'success' do
                specify 'nil first name' do
                  person1.first_name = nil
                  person1.save!
                  person1.merge_with(person1b.id)
                  expect(person1.first_name).to eq(person1b.first_name)
                end
              end
            end

            context 'cached' do
              specify 'cached get updated' do
                person1.prefix = nil
                person1.save!
                person1.merge_with(person1b.id)
                expect(person1.cached.include?('Dr.')).to be_truthy
              end
            end
          end

          context 'vetting' do
            context 'unvetted l_person' do
              specify 'unvetted r_person' do
                # An interesting anomoly occures when person1b is used in place of person1c.
                # In this context, use of person1b seems to result in person1 being converted to 'vetted'
                # (because person1b has been converted to 'vetted'),
                # even though it is otherwise *not* specifically set one way or the other during creation.
                # This seems to be an artifact of the fact that when a person is applied to a taxon name
                # as 'taxon_name_author', that person is (sometimes!) converted to 'vetted'.
                person1.merge_with(person1c.id)
                expect(person1.type.include?('Unv')).to be_truthy
              end

              specify 'vetted r_person' do
                person1.type = 'Person::Unvetted'
                person1.save!
                person1b.type = 'Person::Vetted'
                person1b.save!
                person1.merge_with(person1b.id)
                expect(person1.type.include?(':V')).to be_truthy
              end
            end
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
        gr1.georeferencers << vp
        gr1.save!
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
