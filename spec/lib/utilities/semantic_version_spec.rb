require 'rails_helper'

describe 'Utilities::SemanticVersion' do

  context '.valid?' do
    %w{1.0.0 0.1.0 0.0.1 10.20.30 1.2.3}.each do |v|
      specify "#{v} is valid" do
        expect(Utilities::SemanticVersion.valid?(v)).to be_truthy
      end
    end

    [
      '0.0.0', # at least one non-zero digit
      '1', '1.0', '1.0.0.0', # exactly three parts
      '01.0.0', '1.00.0', '1.0.01', # no leading zeros
      'v1.0.0', '1.0.0-alpha', '1.0.0+build', # no prefix or suffix
      ' 1.0.0', '1.0.0 ', '1..0', 'a.b.c', ''
    ].each do |v|
      specify "'#{v}' is not valid" do
        expect(Utilities::SemanticVersion.valid?(v)).to be_falsey
      end
    end

    specify 'nil is not valid' do
      expect(Utilities::SemanticVersion.valid?(nil)).to be_falsey
    end
  end

end
