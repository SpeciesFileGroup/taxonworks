require 'rails_helper'

describe Person, type: :model, group: :people do

  let(:root_taxon_name) { Protonym.create!(name: 'Root', rank_class: 'NomenclaturalRank', parent_id: nil) }
  let(:tn1) { Protonym.create!(name: 'Aonedidae', parent: root_taxon_name, rank_class: Ranks.lookup(:iczn, :family)) }
  let(:tn2) { Protonym.create!(name: 'Atwodidae', parent: root_taxon_name, rank_class: Ranks.lookup(:iczn, :family)) }

  let!(:person1) do 
    FactoryBot.create(
      :person,
      first_name: 'January', last_name: 'Smith',
      prefix: 'Dr.', suffix: 'III')
  end 

  let(:gr2) { FactoryBot.create(:valid_georeference) }

  let(:da1) { FactoryBot.create(
    :valid_data_attribute_internal_attribute,
    value: 'Dr.',
    predicate: cvt) }

  let(:cvt) { FactoryBot.create(
    :valid_controlled_vocabulary_term_predicate,
    name: ' Honorific',
    definition: 'People:Honorific imported from INHS FileMaker database.') }

  let!(:person1b) do 
    FactoryBot.create(
      :person,
      first_name: 'January', last_name: 'Smith',
      prefix: 'Dr.', suffix: 'III',
      year_born: 2000, year_died: 2015,
      year_active_start: 2012, year_active_end: 2015)
  end 

  let(:person1c) do 
     FactoryBot.create(
      :person,
      first_name: 'January', last_name: 'Smith',
      prefix: 'Dr.', suffix: 'III',
      year_born: 2000, year_died: 2015,
      year_active_start: 2012, year_active_end: 2015)
  end 

  let(:av1) { FactoryBot.create(:valid_alternate_value,
                                value:                            'Jan',
                                alternate_value_object_attribute: 'first_name',
                                alternate_value_object:           person1b) }

  let(:av2) { FactoryBot.create(:valid_alternate_value,
                                value:                            'Janco',
                                alternate_value_object_attribute: 'first_name',
                                alternate_value_object:           person1) }

  let(:id1) { FactoryBot.create(:valid_identifier) }

  let(:no1) { FactoryBot.create(:valid_note) }
  
  let(:da2) { FactoryBot.create(:valid_data_attribute_internal_attribute,
                                value:     'Mr.',
                                predicate: cvt) }


  let(:gr1) { FactoryBot.create(:valid_georeference) }

  context 'roles' do
    before do 
      gr2.georeferencers << person1
      tn1.taxon_name_authors << person1b 
      tn2.taxon_name_authors << person1b 
      gr1.georeferencers << person1b 
    end

    specify 'exist' do
      expect(Role.count).to eq(4)
    end

    specify 'are combined' do
      person1.merge_with(person1b.id)
      expect(person1.roles.map(&:type)).to contain_exactly('TaxonNameAuthor', 'Georeferencer', 'Georeferencer', 'TaxonNameAuthor')
    end

    specify 'are not destroyed' do
      person1.merge_with(person1b.id)
      expect(Role.count).to eq(4)
    end
  end

  context 'roles 2' do
    let!(:p1) { Person.create!(last_name: 'Smith') }
    let!(:p2) { Person.create!(last_name: 'Jones') }

    let!(:s1) { FactoryBot.create(:valid_source) }
    let!(:s2) { FactoryBot.create(:valid_source) }

    let!(:r1) { SourceAuthor.create!(person: p1, role_object: s1) }
    let!(:r2) { SourceAuthor.create!(person: p2, role_object: s2) }

    specify 'merge 1' do
      p1.merge_with(p2.id)
      expect(Role.count).to eq(2)
    end

    specify 'merge 2' do
      p1.merge_with(p2.id)
      expect(p1.roles.count).to eq(2)
    end

    specify 'merge 3' do
      p1.merge_with(p2.id)
      expect(p2.roles.count).to eq(0)
    end

    specify 'merge 4' do
      p1.merge_with(p2.id)
      expect(Role.all.map(&:person_id)).to contain_exactly(p1.id, p1.id)
    end

    specify 'merge 5' do
      p1.merge_with(p2.id)
      expect(p2.reload).to be_truthy
    end

    specify 'merge 6' do
      expect(p1.merge_with(p1.id)).to be_falsey
    end

    specify '#hard_merge 1' do
      p1.hard_merge(p2.id)
      expect{p2.reload}.to raise_error ActiveRecord::RecordNotFound
    end

    specify '#hard_merge 2' do
      expect(p1.hard_merge(p1.id)).to be_falsey
    end

    specify '#hard_merge 3' do
      expect(p1.hard_merge(999)).to be_falsey
    end
  end


  context 'years are combined' do
    context 'fills target year' do
      specify 'if empty' do
        person1.merge_with(person1b.id)
        expect(person1.year_born).to eq(person1b.year_born)
      end

      specify 'if source start earlier' do
        person1.update(year_active_start: person1b.year_active_start + 1)
        person1.merge_with(person1b.id)
        expect(person1.year_active_start).to eq(person1b.year_active_start)
      end

      specify 'if source start later' do
        person1.update!(year_active_start: person1b.year_active_start - 1)
        pre = person1.year_active_start
        person1.merge_with(person1b.id)
        expect(person1.year_active_start).to eq(pre)
      end

      specify 'if source end later' do
        person1.update(year_active_end: person1b.year_active_end - 1)
        person1.merge_with(person1b.id)
        expect(person1.year_active_end).to eq(person1b.year_active_end)
      end

      specify 'if source end earlier' do
        person1.update(year_active_end: person1b.year_active_end + 1)
        pre = person1.year_active_end
        person1.merge_with(person1b.id)
        expect(person1.year_active_end).to eq(pre)
      end
    end
  end

  context 'prefix is combined' do
    specify 'source is nil' do
      person1.update(prefix: nil)
      person1.merge_with(person1b.id)
      expect(person1.prefix).to eq(nil) # eq(person1b.prefix) #DD removed to preserve properly curated names
    end
  end

  context 'suffix is combined' do

    # @tuckerjd whitespace and blank are converted to nil
    # on save, i.e. previous tests in this block
    # weren't doing anything new 
    specify 'source is nil' do
      person1.update(suffix: nil)
      # expect(person1.suffix).to eq(nil)
      person1.merge_with(person1b.id)
      expect(person1.suffix).to eq(nil) # eq(person1b.suffix) #DD removed to preserve properly curated names
    end
  end

  context 'data_attributes' do
    before do
      person1.data_attributes << da1
      person1b.data_attributes << da2
    end

    specify 'data_attributes are combined' do
      person1.merge_with(person1b.id)
      person1.reload # TODO: Wondering why this 'reload' is requied?
      expect(person1.data_attributes.map(&:value)).to include('Mr.', 'Dr.')
    end

  end

  specify 'identifiers' do
    person1b.identifiers << id1
    person1.merge_with(person1b.id)
    expect(person1.identifiers.reload).to include(id1)
  end

  specify 'notes' do
    person1b.notes << no1
    person1.merge_with(person1b.id)
    expect(person1.notes.reload).to include(no1)
  end

  context 'alternate values' do
    specify 'moving alternate value from one to another' do
      av1
      person1.merge_with(person1b.id)
      expect(person1.alternate_values.reload.pluck(:id)).to include(av1.id)
    end

    context 'different names' do
      specify 'first name' do
        person1b.update(first_name: 'Janco')
        person1.merge_with(person1b.id)
        expect(person1.alternate_values.reload.last.value).to include(person1b.first_name)
      end

      specify 'first name with matching alternate value' do
        av2 # person1.first_name = January, person1.altername_value.first.value = Janco
        person1b.update(first_name: 'Janco')
        # this will try to add Janco as an alternate_value, but skip
        person1.merge_with(person1b.id)
        expect(person1.alternate_values.count).to eq(1)
      end

      specify 'last name' do
        person1b.update(last_name: 'Smyth')
        person1.merge_with(person1b.id)
        expect(person1.alternate_values.reload.last.value).to include(person1b.last_name)
      end
    end
  end

  context 'names' do
    context 'r_person' do
      context 'truthyness' do
        specify 'nil first name' do
          person1b.update(first_name: nil)
          trial = person1.merge_with(person1b.id)
          expect(trial).to be_truthy
        end
      end

      context 'success' do
        specify 'nil first name' do
          person1b.update(first_name: nil)
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
        person1.update(prefix: nil)
        person1.merge_with(person1b.id)
        expect(person1.cached.include?('Dr.')).to be_falsey # be_truthy #DD removed to preserve properly curated names
      end
    end
  end

  context 'vetting' do
    specify 'merging two unvetted people is an unvetted person' do
      # there are no roles in either!
      # there are no attributes in either!

      person1.merge_with(person1c.id)
      expect(person1.type).to eq('Person::Unvetted')
    end

    specify 'merging a vetted person, into an unvetted person vets person' do
      tn1.taxon_name_authors << person1c
      tn2.taxon_name_authors << person1c
      # expect(person1c.reload.type).to eq('Person::Vetted')
      person1.merge_with(person1c.id)
      expect(person1.reload.type).to eq('Person::Vetted') # The role is merged, the person is vetted
    end
  end

  # When a source lists the same person 2x, and that person is merged
  context 'double authored sources' do
    let!(:role_object) { FactoryBot.create(:valid_source_bibtex) }
    let!(:role1) { SourceAuthor.create(person: person1, role_object: role_object) }
    let!(:role2) { SourceAuthor.create(person: person1b, role_object: role_object) }

    specify 'can not be merged' do
      expect(person1.merge_with(person1b.id)).to be_falsey
    end
  end 

  specify '#hard_merge, #first_name is preserved' do
    p_keep = Person.create!(first_name: 'Simon', last_name: 'Smith')
    p_destroy = Person.create!(first_name: 'S.', last_name: 'Smith')

    p_keep.hard_merge(p_destroy.id)
    p_keep.reload
    
    expect(p_keep.first_name).to eq('Simon')
  end
  
end
