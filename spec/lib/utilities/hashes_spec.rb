require 'rails_helper'

describe Utilities::Hashes do

  describe '#puts_collisions' do
    let(:hsh) {
      {
        foo: 'bar',
        collision: 2
      }
    }

    # TODO: Resolve testing puts, specs disabled for now...

    xit 'outputs collision' do
      expect(Utilities::Hashes::puts_collisions(hsh, {foo: 'bar', collision: 4})).to output('collision: [2] != [4]')
    end

    xit 'produces no output if no collisions are detected' do
      expect(Utilities::Hashes::puts_collisions(hsh, {bar: 3})).to output(nil)
    end
  end

  describe '#delete_keys' do
    let (:hsh) {
      {
        foo: 'bar',
        one: 1,
        two: '2',
        bar: 'foo'
      }
    }

    it 'deletes all matched keys' do
      expect(Utilities::Hashes.delete_keys(hsh, [:foo, :bar])).to eq({one: 1, two: '2'})
    end

    it 'does not delete unmatched keys' do
      expect(Utilities::Hashes.delete_keys(hsh.clone, [:not_foo, :not_bar])).to eq(hsh)
    end

    it 'returns same hash when modified' do
      expect(Utilities::Hashes.delete_keys(hsh, [:foo])).to equal(hsh)
    end

    it 'returns same hash when not modified' do
      expect(Utilities::Hashes.delete_keys(hsh, [:missing_key])).to equal(hsh)
    end
  end

  describe '#symbolize_keys' do
    let (:hsh) {
      {
        4 => 'integer key',
        :symbol => 'symbol key',
        'foo' => 'string key',
        'hash' => {
          'string' => 'another string key'
        },
        inner_hash: {
          :symbol => 'another symbol key',
          2 => 'another integer key',
          'bar' => 'yet another string key'
        }
      }
    }
    let (:new_hsh) { Utilities::Hashes.symbolize_keys(hsh) }
    let (:new_keys) { new_hsh.keys + [:hash, :inner_hash].map { |s| new_hsh[s].keys }.flatten }

    it 'converts string keys to symbols' do
      expect(new_keys).to include(:foo, :hash, :string, :bar)
    end

    it 'does not convert non-string keys to symbols' do
      symbol_keys = new_keys.select { |k| k.is_a?(Symbol) }
      expect(symbol_keys.size).to eq(7)
    end

    it 'traverses the hash recursively' do
      expect(new_hsh[:hash]).to eq({string: 'another string key'})
    end
    
    it 'returns new copy when modified' do
      expect(new_hsh).to_not equal(hsh)
    end

    it 'returns new copy when not modified' do
      expect(Utilities::Hashes.symbolize_keys(new_hsh)).to_not equal(new_hsh)
    end
  end

  describe '#set_unless_nil' do
    let(:hsh) {
      { foo: 'bar' }
    }

    it 'sets value into hash when it is not nil' do
      Utilities::Hashes::set_unless_nil(hsh, :test, true)
      expect(hsh).to eq({foo: 'bar', test: true})
    end

    it 'does not set value into hash when it is nil' do
      Utilities::Hashes::set_unless_nil(hsh, :foo, nil)
      expect(hsh).to eq({ foo: 'bar' })
    end
  end

  describe '#delete_nil_and_empty_hash_values' do
    let (:clean_hsh) {
      {
        foo: 'hello',
        bar: {
          b: 'bye'
        }
      }
    }
    let(:hsh) {
      clean_hsh.merge({
        nil: nil,
        empty: {}
      })
    }
    let(:new_hsh) { Utilities::Hashes.delete_nil_and_empty_hash_values(hsh) }

    it 'removes nil values from hash' do
      expect(new_hsh).to eq(clean_hsh)
    end

    it 'returns same hash when modified' do
      expect(new_hsh).to equal(hsh)
    end

    it 'returns same hash when not modified' do
      expect(Utilities::Hashes.delete_nil_and_empty_hash_values(clean_hsh)).to equal(clean_hsh)
    end
  end
end
