require 'rails_helper'

describe Utilities::Rails::Strings do

  let(:l) { Utilities::Rails::Strings }

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

end
