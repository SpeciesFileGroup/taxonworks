require 'rails_helper'
describe 'Roles::Person', type: :model do
  let(:p1) { Person.create!(last_name: 'Root') }

  specify '#active_start when Collector created *not* updated on Role create ' do
    a = 4.years.from_now.year
    FactoryBot.create(:valid_collecting_event, collectors: [p1], start_date_year: a)
    expect(p1.year_active_start).to eq(nil)
  end

  specify '#active_end when Collector created *not* updated on Role create ' do
    a = 4.years.from_now.year
    FactoryBot.create(:valid_collecting_event, collectors: [p1], start_date_year: a)
    expect(p1.year_active_end).to eq(nil)
  end

  specify '#active_start/end and Collector *not* updated on role create ' do
    a = 4.years.from_now.year
    FactoryBot.create(:valid_collecting_event, collectors: [p1], start_date_year: a)
    expect(p1.valid?).to be_truthy
  end

  specify '#active_start and TaxonDetermination updated on create' do
    t = FactoryBot.create(:valid_taxon_determination, determiners: [p1], year_made: 2020)
    p1.reload
    expect(p1.year_active_start).to eq(2020)
    expect(p1.year_active_end).to eq(2020)
  end

  specify '#active_start and Source/SourceAuthor updated on create' do
    t = FactoryBot.create(:valid_source_bibtex, authors: [p1], year: 2020)
    p1.reload
    expect(p1.year_active_start).to eq(2020)
    expect(p1.year_active_end).to eq(2020)
  end

  specify '#active_start and Source/SourceEditor updated on create' do
    t = FactoryBot.create(:valid_source_bibtex, editors: [p1], year: 2020)
    p1.reload
    expect(p1.year_active_start).to eq(2020)
    expect(p1.year_active_end).to eq(2020)
  end

  specify '#active_start and Georeference updated on create' do
    t = FactoryBot.create(:valid_georeference, georeferencers: [p1], year_georeferenced: 2021)
    p1.reload
    expect(p1.year_active_start).to eq(2021)
    expect(p1.year_active_end).to eq(2021)
  end

  specify '#active_start and TaxonNameAuthor updated on create' do
    t = FactoryBot.create(:valid_taxon_name, taxon_name_authors: [p1], year_of_publication: 1974)
    p1.reload
    expect(p1.year_active_start).to eq(1974)
    expect(p1.year_active_end).to eq(1974)
  end

  specify '#active_start and TaxonNameAuthor updated on create' do
    t = FactoryBot.create(:valid_collecting_event, collectors: [p1], start_date_year: 1920, end_date_year: 1921)
    p1.reload
    expect(p1.year_active_start).to eq(1921)
    expect(p1.year_active_end).to eq(1921)
  end

  specify '#active_start and LoanRecipient updated on create' do
    t = FactoryBot.create(:valid_loan, loan_recipients: [p1], date_requested: '2001-1-1')
    p1.reload
    expect(p1.year_active_start).to eq(2001)
    expect(p1.year_active_end).to eq(2001)
  end

  specify '#active_start and LoanSupervisor updated on create' do
    t = FactoryBot.create(:valid_loan, loan_supervisors: [p1], date_requested: '2001-1-1')
    p1.reload
    expect(p1.year_active_start).to eq(2001)
    expect(p1.year_active_end).to eq(2001)
  end

  specify '#active_start and Collector updated on role update' do
    t = FactoryBot.create(:valid_collecting_event, collectors: [p1], start_date_year: 1920, end_date_year: 1921)
    p2 = Person.create!(last_name: 'Second')
    t.collector_roles.first.update!(person: p2)
    p2.reload
    expect(p2.year_active_start).to eq(1921)
    expect(p2.year_active_end).to eq(1921)

    expect(p2.year_active_start).to eq(1921)
    expect(p2.year_active_end).to eq(1921)
  end

end
