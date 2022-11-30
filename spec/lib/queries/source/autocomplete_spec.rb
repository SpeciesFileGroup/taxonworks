require 'rails_helper'

require_relative "shared_context"

describe Queries::Source::Autocomplete, type: :model, group: [:sources] do

  # let() statements are here, careful, they are used in filter specs as well
  include_examples 'source queries'

  let(:query) { Queries::Source::Autocomplete.new('') }

  specify '#autocomplete_start_of_author 1' do
    query.terms = 'Smith' 
    expect(query.autocomplete_start_of_author.map(&:id)).to contain_exactly(s2.id, s3.id)
  end

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

  specify '#autocomplete_ordered_wildcard_pieces_in_cached 1' do
    query.terms = 'Bad rubyco'
    expect(query.autocomplete_ordered_wildcard_pieces_in_cached.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_ordered_wildcard_pieces_in_cached 2' do
    query.terms = 'Smi rubyco'
    expect(query.autocomplete_ordered_wildcard_pieces_in_cached.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_ordered_wildcard_pieces_in_cached 3' do
    query.terms = 'Smi 1921 rubyco'
    expect(query.autocomplete_ordered_wildcard_pieces_in_cached.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_year_letter 1' do
    query.terms = '1921a'
    expect(query.autocomplete_year_letter.map(&:id)).to contain_exactly(s3.id)
  end

  specify '#autocomplete_year_letter 2' do
    query.terms = '1921'
    expect(query.autocomplete_year_letter.nil?).to be_truthy
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

  #  specify 'autocomplete_wildcard_author_exact_year' do # query removed from the list (not useful)
  #  query.terms = 'ones andt 1924'
  #  expect(query.autocomplete_wildcard_author_exact_year.map(&:id).first).to eq(s4.id)
  # end

  specify 'autocomplete_cached_wildcard_anywhere 1' do
    query.terms = 'andt Things about'
    expect(query.autocomplete_cached_wildcard_anywhere.map(&:id).first).to eq(s4.id)
  end

  specify 'autocomplete_wildcard_anywhere_exact_year 1' do
    query.terms = '1940 Lagoon'
    expect(query.autocomplete_wildcard_anywhere_exact_year.map(&:id).first).to eq(s5.id)
  end

  specify 'autocomplete_wildcard_anywhere_exact_year 2' do
    query.terms = 'Lagoon 1940'
    expect(query.autocomplete_wildcard_anywhere_exact_year.map(&:id).first).to eq(s5.id)
  end

  specify 'autocomplete_wildcard_anywhere_exact_year 3' do
    query.terms = 'Lagoon 1940 Black'
    expect(query.autocomplete_wildcard_anywhere_exact_year.map(&:id).first).to eq(s5.id)
  end

  specify 'autocomplete_cached_wildcard_anywhere' do
    query.terms = 'black brandt'
    expect(query.autocomplete_cached_wildcard_anywhere.map(&:id).first).to eq(s5.id)
  end

  specify '#autocomplete 1' do
    query.terms = 'Smith 1921a'
    expect(query.autocomplete.map(&:id).first).to eq(s3.id)
  end

  #specify '#autocomplete 2' do ## query removed from the list (not useful)
  #  query.terms = 'Smith 1921z'
  #  expect(query.autocomplete.map(&:id).first).to eq(s3.id)
  #end

end
