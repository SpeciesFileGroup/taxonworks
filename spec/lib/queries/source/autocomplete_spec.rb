require 'rails_helper'

describe Queries::Source::Autocomplete, type: :model do

  # Authors
  let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }
  let(:p2) { FactoryBot.create(:valid_person, last_name: 'Jones') }
  let(:p3) { FactoryBot.create(:valid_person, last_name: 'Brandt', prefix: 'von') }

  let(:j1) { FactoryBot.create(:valid_serial, name: 'Journal of Stuff and Things') }
  let!(:a1) { AlternateValue::Abbreviation.create!(value: 'J. S. and T.', alternate_value_object: j1, alternate_value_object_attribute: :name) }

  let!(:s1) { Source::Verbatim.create!(
    verbatim: 'Grumwald, 1981. Things I Mumble. J. Unintelligible Speach. 22: 1-19') 
  } 
  
  let!(:s2) { Source::Bibtex.create!(
    bibtex_type: :article,
    authors: [p1], 
    year: 1920, 
    title: 'Bad cops, good cops, rubocops.'
  )}

  let!(:s3) { Source::Bibtex.create!(
    bibtex_type: :article,
    author: 'Smith', 
    year: 1921,
    year_suffix: 'a',
    title: 'Bad cops, good caps, rubycoats.'
  )}

  let!(:s4) { Source::Bibtex.create!(
    bibtex_type: :article,
    authors: [p2, p3, p1], 
    year: 1924, 
    title: 'We all got together and wrote about Things!'
  )}

  let!(:s5) { Source::Bibtex.create!(
    bibtex_type: :article,
    author: 'von Brandt & Bartholemew', 
    year: 1940, 
    title: 'Creatures from the Black Lagoon.',
    serial: j1
  )}

  let!(:s6) { Source::Verbatim.create!(verbatim: 'foo' )  }

  # Sources in prquoject 
  # Sources not in project
  
  let(:query) { Queries::Source::Autocomplete.new('') }

  specify '#autocomplete_exact_author 1' do
    query.terms = 'Smith' 
    expect(query.autocomplete_exact_author.map(&:id)).to contain_exactly(s2.id, s3.id)
  end

  specify '#autocomplete_any_author 1' do
    query.terms = 'Smith' 
    expect(query.autocomplete_any_author.map(&:id)).to contain_exactly(s2.id, s3.id, s4.id)
  end

  specify '#autocomplete_any_author 2' do
    query.terms = 'Smit' 
    expect(query.autocomplete_any_author.map(&:id)).to contain_exactly()
  end

  specify '#autocomplete_partial_author 1' do
    query.terms = 'Smit' 
    expect(query.autocomplete_partial_author.map(&:id)).to contain_exactly(s2.id, s3.id, s4.id)
  end

  specify '#autocomplete_year 1' do
    query.terms = 'Smith, 1940, Bogus 1924a'
    expect(query.autocomplete_year.map(&:id)).to contain_exactly(s4.id, s5.id)
  end

  specify '#autocomplete_start_of_title 1' do
    query.terms = 'Bad cops'
    expect(query.autocomplete_start_of_title.map(&:id)).to contain_exactly(s2.id, s3.id)
  end

  specify '#autocomplete_wildcard_pieces 1' do
    query.terms = 'Bad rubyco'
    expect(query.autocomplete_wildcard_pieces.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_wildcard_pieces 2' do
    query.terms = 'Smi rubyco'
    expect(query.autocomplete_wildcard_pieces.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_wildcard_pieces 3' do
    query.terms = 'Smi 1921 rubyco'
    expect(query.autocomplete_wildcard_pieces.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_year_letter 1' do
    query.terms = '1921a'
    expect(query.autocomplete_year_letter.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_year_letter 2' do
    query.terms = '1921'
    expect(query.autocomplete_year_letter.map(&:id)).to contain_exactly()
  end

  specify '#autocomplete_exact_author_year_letter 1' do
    query.terms = 'Smith 1921a'
    expect(query.autocomplete_exact_author_year_letter.map(&:id).first).to eq(s3.id)
  end

  specify '#autocomplete_exact_author_year 1' do
    query.terms = 'Smith 1921a'
    expect(query.autocomplete_exact_author_year.map(&:id).first).to eq(s3.id)
  end

  specify '#autocomplete_wildcard_pieces_and_year' do
    # !! cached currently renders von on the outside, so `von Brandt` won't match
    query.terms = 'Jones, Brandt & Smith, 1924'
    expect(query.autocomplete_wildcard_pieces_and_year.map(&:id).first).to eq(s4.id)
  end

  specify 'autocomplete_wildcard_author_exact_year' do
    query.terms = 'ones andt 1924'
    expect(query.autocomplete_wildcard_author_exact_year.map(&:id).first).to eq(s4.id)
  end

  specify 'autocomplete_wildcard_anywhere 1' do
    query.terms = 'andt Things about'
    expect(query.autocomplete_wildcard_anywhere.map(&:id).first).to eq(s4.id)
  end

  specify 'autocomplete_wildcard_anywhere 2' do
    query.terms = 'black brandt'
    expect(query.autocomplete_wildcard_anywhere.map(&:id).first).to eq(s5.id)
  end

  # ----

  specify '#autocomplete 1' do
    query.terms = 'Smith 1921a'
    expect(query.autocomplete.map(&:id).first).to eq(s3.id)
  end

  specify '#autocomplete 2' do
    query.terms = 'Smith 1921z'
    expect(query.autocomplete.map(&:id).first).to eq(s3.id)
  end




end
