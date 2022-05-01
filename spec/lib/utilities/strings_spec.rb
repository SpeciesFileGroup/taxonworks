# TODO: Extract all this to a gem

# TODO: by definition of being in Utilities this shouldn't be required
require 'rails_helper'

describe Utilities::Strings do

  let(:l) { Utilities::Strings }

  specify '.alphabetic_strings 1' do
    expect(l.alphabetic_strings('a b 2 c')).to contain_exactly('a', 'b', 'c')
  end

  specify '.alphabetic_strings 2' do
    expect(l.alphabetic_strings('a b2 2a a2a')).to contain_exactly('a')
    end

  specify '.alphabetic_strings should not have empty elements with multiple adjacent separator characters' do
    expect(l.alphabetic_strings('abc, 1')).to contain_exactly('abc')
  end

  specify '.alphabetic_strings should split ' do
    expect(l.alphabetic_strings("who's there?")).to contain_exactly('who', 's', 'there')
  end

  specify '.alphabetic_strings should not split on underscore' do
    expect(l.alphabetic_strings("underscored_word other word")).to contain_exactly('underscored_word', 'other', 'word')
  end

  specify '.alphabetic_strings should split on accent characters' do
    expect(l.alphabetic_strings("Hernán")).to contain_exactly('Hernán')
  end

  specify '.random_string' do
    expect(l.random_string(5).length).to eq(5)
  end

  specify '.random_string' do
    expect(l.random_string(0)).to be_nil
  end

  # specify '.nil_strip 0' do
  #   expect(l.nil_strip("\u0000")).to eq(nil)
  # end

  specify '.nil_strip 1' do
    expect(l.nil_strip('   ')).to eq(nil)
  end

  specify '.nil_strip 2' do
    expect(l.nil_strip(' abc  ')).to eq('abc')
  end

  specify '.nil_strip 3' do
    expect(l.nil_strip(" a  b\n  c  ")).to eq("a  b\n  c")
  end

  specify ".nil_strip nil returns nil" do
    expect(l.nil_strip(nil)).to be_nil
  end

  specify '.nil_squish_strip 0' do
    expect(l.nil_squish_strip("\u0000 \u0000\u0000  ")).to eq(nil)
  end

  specify '.nil_squish_strip 1' do
    expect(l.nil_squish_strip("  ")).to eq(nil)
  end

  specify '.nil_squish_strip 2' do
    expect(l.nil_squish_strip("  a \n  \n b  ")).to eq('a b')
  end

  specify ".nil_squish_strip 3" do
    expect(l.nil_squish_strip(nil)).to be_nil
  end

  specify '.generate_md5' do
    expect(l.generate_md5('foo')).to eq('acbd18db4cc2f85cedef654fccc4a4d8')
  end

  specify '.increment_contained_integer' do
    expect(l.increment_contained_integer(nil)).to eq(false)
  end

  specify '.increment_contained_integer 2' do
    expect(l.increment_contained_integer('a1b')).to eq('a2b')
  end

  specify '.increment_contained_integer 3' do
    expect(l.increment_contained_integer('a1b')).to eq('a2b')
  end

  specify '.increment_contained_integer 4' do
    expect(l.increment_contained_integer('a1b2c')).to eq('a2b')
  end

  specify '.increment_contained_integer 5' do
    expect(l.increment_contained_integer('a1.2b2c')).to eq('a2.')
  end

  specify '.increment_contained_integer 5' do
    expect(l.increment_contained_integer('9')).to eq('10')
  end

  specify '.increment_contained_integer 6' do
    expect(l.increment_contained_integer('a09')).to eq('a10')
  end

  specify '.escape_single_quote 1' do
    expect(l.escape_single_quote("'")).to eq("''")
  end

  specify '.escape_single_quote 2' do
    expect(l.escape_single_quote("")).to be_nil
  end

  specify '.is_i? 1' do
    expect(l.is_i?("\n")).to eq(false)
  end

  specify '.is_i? 2' do
    expect(l.is_i?('2.2')).to eq(false)
  end

  specify '.is_i? 3' do
    expect(l.is_i?('22222')).to eq(true)
  end

  specify '.is_i? 4' do
    expect(l.is_i?('02')).to eq(true)
  end

  specify '.sanitize_for_csv 1' do
    expect(l.sanitize_for_csv('02')).to eq('02')
  end

  specify '.sanitize_for_csv 2' do
    expect(l.sanitize_for_csv("abc\tdef")).to eq('abc def')
  end

  # !! new line technically OK
  specify '.sanitize_for_csv 3' do
    expect(l.sanitize_for_csv("abc\ndef")).to eq('abc def')
  end

  specify '.sanitize_for_csv 4' do
    expect(l.sanitize_for_csv("    ")).to eq('    ')
  end

  specify '.sanitize_for_csv 5' do
    expect(l.sanitize_for_csv("")).to eq('')
  end

  specify '.nil_wrap 1' do
    expect(l.nil_wrap(nil, 'b', 'c')).to eq('bc')
  end

  specify '.nil_wrap 2' do
    expect(l.nil_wrap('a', 'b')).to eq('ab')
  end

  specify ".nil_wrap 3" do
    expect(l.nil_wrap('a', ' ', 'c')).to be_nil
  end

  specify '#years' do
    expect(l.years('192 1432 1432 1922 1 22 a1923 b')).to contain_exactly('1432', '1922', '1923')
  end

  specify '#year_letter 1' do
    expect(l.year_letter('1922a')).to eq('a')
  end

  specify '#year_letter 2' do
    expect(l.year_letter('1922aa b')).to eq('aa')
  end

  specify '#integers 1' do
    expect(l.integers('1922aa b 123')).to contain_exactly('123')
  end

  specify '#integers 2' do
    expect(l.integers('')).to eq([])
  end

  specify '#integers 3' do
    expect(l.integers(nil)).to eq([])
  end

  specify '#only_integers? 1' do
    expect(l.only_integers?('1922aa b 123')).to eq(false)
  end

  specify '#only_integers? 2' do
    expect(l.only_integers?('1922 0 123')).to eq(true)
  end

end
