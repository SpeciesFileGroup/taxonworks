require 'rails_helper'

# !! These specs also contain the canonical specs for Queries::Concerns::Users.

describe Queries::Person::Filter, type: :model, group: :people do

  let!(:p1) { Person.create!(
    last_name: 'Smith') }

  let!(:p2) { Person.create!(
    last_name:  'Smith',
    first_name: 'Sarah') }

  let!(:p3) { Person.create!(
    last_name: 'Brandt',
    prefix: 'von',
    first_name: 'Charlie',
    suffix: 'III') }

  let!(:p4) { Person.create!(
    last_name: 'Snopapopolus',
    first_name: 'George') }

  let(:collecting_event) {
    CollectingEvent.create!(
      verbatim_locality: 'Neverland',
      with_verbatim_data_georeference: true,
      verbatim_latitude: '10',
      verbatim_longitude: '10',
      collectors: [p2]) }

  let(:query) { Queries::Person::Filter.new() }

  specify '#role_total_min' do
    query.role_total_min = 2
    expect(query.all.map(&:id)).to be_empty
  end

  specify '#role_total_min 2' do
    collecting_event
    s = FactoryBot.create(:valid_source, authors: [p2]) # p1 an author, not eliminated
    query.role_total_min = 2
    expect(query.all.map(&:id)).to contain_exactly(p2.id)
  end

  specify '#repeated_total' do
    query.repeated_total = 2
    expect(query.all.map(&:id)).to be_empty
  end

  specify '#without' do
    query.without = ['first_name']
    expect(query.all.map(&:id)).to contain_exactly(p1.id)
  end

  specify '#without 2' do
    query.without = ['prefix']
    expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id, p4.id)
  end

  specify '#regex' do
    query.regex = '.*t[h]'
    expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id)
  end

  specify '#regex 2' do
    query.regex = '\AS.*t'
    expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id)
  end

  specify '#regex 3' do
    query.regex = 'p.p'
    expect(query.all.map(&:id)).to contain_exactly(p4.id)
  end

  specify '#first_name 1' do
    query.first_name = 'e'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#first_name, #exact' do
    query.first_name = 'e'
    query.exact = ['first_name']
    expect(query.all.map(&:id)).to contain_exactly(p3.id, p4.id)
  end

  specify '#last_name 1' do
    query.last_name = 'Smith'
    expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id)
  end

  specify '#last_name, #exact' do
    query.last_name = 'op'
    query.exact = ['last_name']
    expect(query.all.map(&:id)).to contain_exactly(p4.id)
  end

  specify '#except_role' do
    collecting_event # p2 eliminated
    query.last_name = 'Smith'
    query.except_role = ['Collector']
    expect(query.all.map(&:id)).to contain_exactly(p1.id)
  end

  specify '#except_role 2' do
    collecting_event # p2 eliminated
    s = FactoryBot.create(:valid_source, authors: [p1]) # p1 an author, not eliminated
    query.last_name = 'Smith'
    query.except_role = ['Collector']
    expect(query.all.map(&:id)).to contain_exactly(p1.id)
  end

  specify '#role' do
    collecting_event
    query.role = ['Collector']
    expect(query.all.pluck(:id)).to contain_exactly(p2.id)
  end

  specify '#role, #last_name' do
    collecting_event
    query.role = ['Collector']
    query.last_name = 'Smith'
    expect(query.all.pluck(:id)).to contain_exactly(p2.id)
  end

  specify '#role + other 1' do
    s = Source::Bibtex.create!(bibtex_type: :article, title: 'Title', year: 1293)
    s.editors << p3

    query.role = ['SourceEditor']
    query.last_name_starts_with = p3.last_name[0..3]
    expect(query.all.map(&:id)).to contain_exactly(p3.id)
  end

  specify '#name' do
    query.name = 'Smith'
    expect(query.all.pluck(:id)).to contain_exactly(p1.id, p2.id)
  end

  specify '#name' do
    query.name = 'Smith'
    query.exact = ['name']
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#name, #levenshtein_cuttoff 1' do
    query.name = 'Snith'
    query.levenshtein_cuttoff = 2
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#name, #levenshtein_cuttoff 2' do
    query.name = 'Snit'
    query.levenshtein_cuttoff = 3
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#born_after_year' do
    p1.update!(year_born: 2010)
    query.born_after_year = 2009
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#born_before_year' do
    p1.update!(year_born: 2010)
    query.born_before_year = 2011
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#active_after_year' do
    p1.update!(year_active_start: 2010)
    query.active_after_year = 2009
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#active_after_year' do
    p1.update!(year_active_end: 2010)
    query.active_after_year = 2009
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#active_before_year 1' do
    p1.update!(year_active_start: 2010)
    query.active_before_year = 2011
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#active_before_year 2' do
    p1.update!(year_active_end: 2010)
    query.active_before_year = 2011
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#died_after_year' do
    p1.update!(year_died: 2010)
    query.died_after_year = 2009
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#died_before_year' do
    p1.update!(year_died: 2010)
    query.died_before_year = 2011
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify '#last_name_starts_with' do
    query.last_name_starts_with = 'Sm'
    expect(query.all.pluck(:id)).to contain_exactly(p1.id, p2.id)
  end

  specify '#identifier' do
    i = 'http://orcid.org/0000-0003-5000-0001'
    j = Identifier::Global::Orcid.create!(identifier: i, identifier_object: p1)
    query.identifier = j.cached
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  specify 'abbreviation #last_name' do
    i = AlternateValue::Abbreviation.create!(alternate_value_object: p2, alternate_value_object_attribute: :last_name, value: 'S.')
    query.last_name = 'S.'
    expect(query.all.pluck(:id)).to contain_exactly(p2.id)
  end

  specify 'misspelling #last_name' do
    i = AlternateValue::Misspelling.create!(alternate_value_object: p2, alternate_value_object_attribute: :last_name, value: 'Smyth')
    query.last_name = 'Smyth'
    expect(query.all.pluck(:id)).to contain_exactly(p2.id)
  end

  specify 'abbreviation #first_name' do
    i = AlternateValue::Abbreviation.create!(alternate_value_object: p2, alternate_value_object_attribute: :first_name, value: 'S.')
    query.first_name = 'S.'
    expect(query.all.pluck(:id)).to contain_exactly(p2.id)
  end

  specify 'misspelling #first_name' do
    v = 'Syrah'
    i = AlternateValue::Misspelling.create!(alternate_value_object: p2, alternate_value_object_attribute: :first_name, value: v)
    query.first_name = v
    expect(query.all.pluck(:id)).to contain_exactly(p2.id)
  end

  specify '#only_project_id 1' do
    query.only_project_id = [collecting_event.project_id] # Create the collector and reference project in one place
    expect(query.all.map(&:id)).to contain_exactly(p2.id)
  end

  specify '#project_id 2' do
    s = Source::Bibtex.create!(bibtex_type: :article, title: 'Title', year: 1293)
    s.authors << p3
    c = ProjectSource.create!(source: s, project_id: Current.project_id)

    query.only_project_id = [collecting_event.project_id] # Create the collector and reference project in one place

    expect(query.all.map(&:id)).to contain_exactly(p2.id, p3.id)
  end

  specify '#except_project_id 3' do
    p = FactoryBot.create(:valid_project)
    u = FactoryBot.create(:valid_project_member, user: FactoryBot.create(:valid_user))

    s = Source::Bibtex.create!(bibtex_type: :article, title: 'Title', year: 1293)
    s.authors << p3
    c = ProjectSource.create!(source: s, project_id: p.id)

    collecting_event # not this collector (p2)

    query.except_project_id = [Current.project_id]
    expect(query.all.map(&:id)).to contain_exactly(p3.id)
  end


  # Tested elsewhere, just check to see that they are initialized here
  #
  specify 'tag hooks' do
    k = FactoryBot.create(:valid_keyword)
    p1.tags << Tag.new(keyword: k)
    query.keyword_id_and = [k.id]
    expect(query.all.pluck(:id)).to contain_exactly(p1.id)
  end

  context 'user (Queries::Concerns::Users)' do

    specify '#user_id' do
      query.user_id = Current.user_id
      expect(query.all.pluck(:id)).to contain_exactly(p1.id, p2.id, p3.id, p4.id)
    end

    specify '#user_start_date 1' do
      query.user_date_start = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(updated_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id)
    end

    specify '#user_start_date 2' do
      query.user_date_start = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(created_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id)
    end

    specify '#user_start_date 3' do
      query.user_date_start = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(created_at: '1999-01-01')
      p2.update!(updated_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id)
    end

    specify '#user_end_date 1' do
      query.user_date_end = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(updated_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id)
    end

    specify '#user_end_date 2' do
      query.user_date_end = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(created_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id)
    end

    specify '#user_end_date 3' do
      query.user_date_end = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(created_at: '1999-01-01')
      p2.update!(updated_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id)
    end

    specify '#user_start_date, #user_end_date' do
      query.user_date_start = '1998-01-01'
      query.user_date_end = '1999-01-01'
      query.user_id = Current.user_id
      p1.update!(created_at: '1998-01-01')
      p2.update!(updated_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p1.id, p2.id)
    end

    specify '#user_start_date, #user_end_date, #user_target' do
      query.user_date_start = '1998-01-01'
      query.user_date_end = '1999-01-01'
      query.user_id = Current.user_id
      query.user_target = 'updated'
      p1.update!(created_at: '1998-01-01')
      p2.update!(updated_at: '1999-01-01')
      expect(query.all.map(&:id)).to contain_exactly(p2.id)
    end

    specify '#user_id, #user_target 1' do
      u = FactoryBot.create(:valid_user)
      query.user_id = u.id
      query.user_target = 'updated'
      p1.update!(updated_by_id: u.id)
      expect(query.all.map(&:id)).to contain_exactly(p1.id)
    end

    specify '#user_id, #user_target 2' do
      u = FactoryBot.create(:valid_user)
      query.user_id = u.id
      query.user_target = 'created'
      p2.update!(created_by_id: u.id)
      expect(query.all.map(&:id)).to contain_exactly(p2.id)
    end
  end
end
