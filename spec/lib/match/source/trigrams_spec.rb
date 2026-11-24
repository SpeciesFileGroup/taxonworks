require 'rails_helper'

describe Match::Source::Trigrams, type: :model do
  let(:t) { Match::Source::Trigrams }

  specify 'similarity' do
    c = ['Fleas of Indiana', 'Fleas of Indiana', :similarity]
    expect(t.evaluate([c])[c]).to eq(1.0)
  end

  specify 'word_similarity, how well the first appears in the second' do
    c = ['word', 'two words', :word_similarity]
    expect(t.evaluate([c])[c]).to be_within(1e-6).of(0.8)
  end

  specify 'word_similarity is not symmetric' do
    citation = 'Smith 1990. Fleas of Indiana. J.'
    a = ['Fleas of Indiana', citation, :word_similarity]
    b = [citation, 'Fleas of Indiana', :word_similarity]
    r = t.evaluate([a, b])
    expect(r[a]).to eq(1.0)
    expect(r[b]).to be < 1.0
  end

  specify 'many comparisons at once, repeated strings and comparisons' do
    comparisons = [
      ['abc', 'abc', :similarity],
      ['abc', 'xyz', :similarity],
      ['abc', 'abc', :similarity],
      ['abc', 'abc', :word_similarity]
    ]
    r = t.evaluate(comparisons)
    expect(r.size).to eq(3)
    expect(r[comparisons[1]]).to eq(0.0)
  end

  specify 'quotes strings' do
    c = ["O'Brien's flea", "O'Brien's flea", :similarity]
    expect(t.evaluate([c])[c]).to eq(1.0)
  end

  specify 'nothing to evaluate' do
    expect(t.evaluate([])).to eq({})
  end

  specify 'an unknown function is an error' do
    expect { t.evaluate([['a', 'b', :levenshtein]]) }
      .to raise_error(ArgumentError)
  end
end
