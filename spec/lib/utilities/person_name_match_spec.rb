require 'rails_helper'

describe Utilities::PersonNameMatch do

  let(:m) { Utilities::PersonNameMatch }

  context '.score_first_name_match' do
    specify 'exact match scores 2 per part' do
      expect(m.score_first_name_match('John', 'John')).to eq(2)
    end

    specify 'initial match scores 1' do
      expect(m.score_first_name_match('John', 'J.')).to eq(1)
    end

    specify 'different initial scores 0' do
      expect(m.score_first_name_match('Alice', 'Bob')).to eq(0)
    end

    specify 'empty parsed returns 0' do
      expect(m.score_first_name_match('John', '')).to eq(0)
      expect(m.score_first_name_match('John', nil)).to eq(0)
    end

    specify 'empty stored returns -1' do
      expect(m.score_first_name_match('', 'John')).to eq(-1)
      expect(m.score_first_name_match(nil, 'John')).to eq(-1)
    end

    specify 'multi-part: both exact scores 4' do
      expect(m.score_first_name_match('John Kenneth', 'John Kenneth')).to eq(4)
    end

    specify 'multi-part: first exact second initial scores 3' do
      expect(m.score_first_name_match('John Kenneth', 'John K.')).to eq(3)
    end

    specify 'multi-part: both initial scores 2' do
      expect(m.score_first_name_match('John Kenneth', 'J. K.')).to eq(2)
    end

    specify 'dots are stripped before comparison' do
      expect(m.score_first_name_match('J.', 'J')).to eq(2)
    end
  end

  context '.score_last_name_match' do
    specify 'exact single word scores 2' do
      expect(m.score_last_name_match('Smith', 'Smith')).to eq(2)
    end

    specify 'word in common scores 2 per word' do
      expect(m.score_last_name_match('Smith Jones', 'Smith')).to eq(2)
    end

    specify 'two words in common scores 4' do
      expect(m.score_last_name_match('Smith Jones', 'Smith Jones')).to eq(4)
    end

    specify 'no word in common scores 0' do
      expect(m.score_last_name_match('Jones', 'Smith')).to eq(0)
    end

    specify 'empty parsed returns 0' do
      expect(m.score_last_name_match('Smith', '')).to eq(0)
      expect(m.score_last_name_match('Smith', nil)).to eq(0)
    end

    specify 'empty stored returns -1' do
      expect(m.score_last_name_match('', 'Smith')).to eq(-1)
      expect(m.score_last_name_match(nil, 'Smith')).to eq(-1)
    end

    specify 'matching is case-insensitive' do
      expect(m.score_last_name_match('smith', 'Smith')).to eq(2)
    end
  end

  context '.sort_by_match' do
    let(:person) { Struct.new(:first_name, :last_name) }

    specify 'returns people sorted by descending match score' do
      exact  = person.new('John', 'Smith')
      abbrev = person.new('J.',   'Smith')
      wrong  = person.new('Jane', 'Jones')

      result = m.sort_by_match([wrong, abbrev, exact], 'John', 'Smith')
      expect(result).to eq([exact, abbrev, wrong])
    end
  end

  context '.score_match' do
    specify 'last name match outweighs a better first name match' do
      # partial first + correct last vs. exact first + wrong last
      partial_first_good_last = m.score_match('J.',   'Smith', 'John', 'Smith')
      good_first_wrong_last   = m.score_match('John', 'Jones', 'John', 'Smith')
      expect(partial_first_good_last).to be > good_first_wrong_last
    end

    specify 'full match scores higher than partial' do
      full    = m.score_match('John', 'Smith', 'John', 'Smith')
      partial = m.score_match('J.', 'Smith', 'John', 'Smith')
      expect(full).to be > partial
    end
  end

end
