require 'rails_helper'

describe Queries::Source::Autocomplete, type: :model do

  # Authors
  let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }
  let(:p2) { FactoryBot.create(:valid_person, last_name: 'Jones') }
  let(:p3) { FactoryBot.create(:valid_person, last_name: 'von Brandt') }

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

  # Sources in project 
  # Sources not in project
  
  let(:query) { Queries::Source::Autocomplete.new('') }

  specify '#autocomplete_exact_author 1' do
    query.terms = 'Smith' 
    expect(query.autocomplete_exact_author.map(&:id)).to contain_exactly(s2.id, s3.id)
  end

  specify '#autocomplete_any_author 1' do
    query.terms = 'Smith' 
    expect(query.autocomplete_exact_author.map(&:id)).to contain_exactly(s2.id, s3.id, s4.id)
  end

# specify '#autocomplete_top_name 2' do
#   query.terms = 'Erasmoneura' 
#   expect(query.autocomplete_top_name.first).to eq(genus) 
# end

# specify '#autocomplete_top_cached' do
#   query.terms = name 
#   expect(query.autocomplete_top_cached.first).to eq(species)
# end

# specify '#autocomplete_cached_end_wildcard 3' do
#   query.terms = 'Erasmon'
#   expect(query.autocomplete_cached_end_wildcard.to_a).to contain_exactly(genus, species)
# end

# specify '#autocomplete_wildcard_joined_strings 1' do
#   query.terms = 'vuln'
#   expect(query.autocomplete_wildcard_joined_strings).to include(species)
# end

# specify '#autocomplete_wildcard_joined_strings 2' do
#   query.terms = 'rasmon'
#   expect(query.autocomplete_wildcard_joined_strings.first).to eq(genus)
# end

# specify '#autocomplete_wildcard_joined_strings 3' do
#   query.terms = 'ulner'
#   expect(query.autocomplete_wildcard_joined_strings.first).to eq(species)
# end

# specify '#autocomplete_wildcard_joined_strings 4' do
#   query.terms = 'neur nerat'
#   expect(query.autocomplete_wildcard_joined_strings).to include(species)
# end

# specify '#autocomplete_wildcard_joined_strings 5' do
#   query.terms = 'E vul'
#   expect(query.autocomplete_wildcard_joined_strings.first).to eq(species)
# end

# specify '#autocomplete_wildcard_joined_strings 6' do
#   query.terms = 'E. vul'
#   expect(query.autocomplete_wildcard_joined_strings.first).to eq(species)
# end

# specify '#autocomplete_wildcard_author_year_joined_pieces 1' do
#   query.terms = 'Fitch'
#   expect(query.autocomplete_wildcard_author_year_joined_pieces.first).to eq(species)
# end

# specify '#autocomplete_wildcard_author_year_joined_pieces 2' do
#   query.terms = 'Say'
#   expect(query.autocomplete_wildcard_author_year_joined_pieces.first).to eq(species)
# end

# specify '#autocomplete_wildcard_author_year_joined_pieces 3' do
#   query.terms = '1800'
#   expect(query.autocomplete_wildcard_author_year_joined_pieces.first).to eq(species)
# end

# specify '#autocomplete_wildcard_author_year_joined_pieces 4' do
#   query.terms = 'Fitch 1800'
#   expect(query.autocomplete_wildcard_author_year_joined_pieces.first).to eq(species)
# end


  # etc. ---

end
