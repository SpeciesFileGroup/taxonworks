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

  context 'searching by author and stated_year' do
    let!(:source_with_stated_year) {
      FactoryBot.create(:valid_source_bibtex,
        author: 'Johnson',
        stated_year: '2020',
        year: 2021,
        title: 'A study with stated year'
      )
    }

    let!(:source_with_year) {
      FactoryBot.create(:valid_source_bibtex,
        author: 'Johnson',
        year: 2020,
        stated_year: nil,
        title: 'A study with year'
      )
    }

    specify 'finds source when queried year is in stated_year field' do
      query.terms = 'Johnson 2020'
      expect(query.autocomplete).to include(source_with_stated_year)
    end

    specify 'finds source when queried year is in year field' do
      query.terms = 'Johnson 2021'
      expect(query.autocomplete).to include(source_with_stated_year)
    end

    specify 'finds both sources when searching by author and year' do
      query.terms = 'Johnson 2020'
      result_ids = query.autocomplete.map(&:id)
      expect(result_ids).to include(source_with_stated_year.id, source_with_year.id)
    end
  end

  context 'searching with alternate author values' do
    let!(:source_mueller) {
      FactoryBot.create(:valid_source_bibtex,
        author: 'Müller',
        year: 2000,
        title: 'A study on German names'
      )
    }

    let!(:alternate_mueller) {
      AlternateValue::AlternateSpelling.create!(
        value: 'Mueller',
        alternate_value_object: source_mueller,
        alternate_value_object_attribute: 'author'
      )
    }

    specify '#autocomplete_exact_author_alternate' do
      query.terms = 'Mueller'
      expect(query.autocomplete_exact_author_alternate.map(&:id)).to contain_exactly(source_mueller.id)
    end

    specify '#autocomplete_start_of_author_alternate' do
      query.terms = 'Mue'
      expect(query.autocomplete_start_of_author_alternate.map(&:id)).to contain_exactly(source_mueller.id)
    end

    specify '#autocomplete_exact_author_year_alternate' do
      query.terms = 'Mueller 2000'
      expect(query.autocomplete_exact_author_year_alternate.map(&:id)).to contain_exactly(source_mueller.id)
    end

    specify '#autocomplete_start_author_year_alternate' do
      query.terms = 'Mue 2000'
      expect(query.autocomplete_start_author_year_alternate.map(&:id)).to contain_exactly(source_mueller.id)
    end

    describe '#autocomplete_exact_author_year_letter_alternate' do
      let!(:source_with_suffix) {
        FactoryBot.create(:valid_source_bibtex,
          author: 'Müller',
          year: 2000,
          year_suffix: 'b',
          title: 'Second study on German names'
        )
      }

      let!(:alternate_with_suffix) {
        AlternateValue::AlternateSpelling.create!(
          value: 'Mueller',
          alternate_value_object: source_with_suffix,
          alternate_value_object_attribute: 'author'
        )
      }

      specify 'finds source by alternate author, year and suffix' do
        query.terms = 'Mueller 2000b'
        expect(query.autocomplete_exact_author_year_letter_alternate.map(&:id)).to contain_exactly(source_with_suffix.id)
      end
    end

    specify '#autocomplete returns sources with alternate author' do
      query.terms = 'Mueller 2000'
      expect(query.autocomplete.map(&:id)).to contain_exactly(source_mueller.id)
    end
  end

end
