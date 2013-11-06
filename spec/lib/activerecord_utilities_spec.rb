require 'spec_helper'
require 'activerecord_utilities'

describe 'ActiverecordUtilities' do

  context 'class methods' do
    specify 'nil_trim_attributes correctly assigns' do
      expect(TestStringManipulations.nil_trim_attributes(:col1, :col3)).to be_true
      expect(TestStringManipulations.attributes_to_trim).to match_array [:col1, :col3]
    end
    specify 'nil_trim_attributes raises when invalid attribute passed' do
      expect { TestStringManipulations.nil_trim_attributes(:col1, :foo) }.to raise_error
    end
  end
  context 'instance methods' do
    let(:teststr) {
      TestStringManipulations.nil_trim_attributes(:col1, :col3)
      TestStringManipulations.new
    }

    specify 'trim_attributes' do
      expect(teststr.col1 = ' whitespace ').to be_true
      expect(teststr.col2 = ' unchanged ').to be_true
      expect(teststr.col3 = ' mucho   whitespace in    the Middle    ').to be_true
      teststr.valid?
      expect(teststr.col1).to eq('whitespace')
      expect(teststr.col2).to eq(' unchanged ')
      expect(teststr.col3).to eq('mucho   whitespace in    the Middle')
    end
  end
end

#include dummy class to test the activerecord_utilities
class TestStringManipulations

  attr_accessor :col1, :col2, :col3

  def self.before_validation(*block)
  end

  include ActiverecordUtilities

  def self.column_names
    %w(col1 col2 col3)
  end

  def valid?
    trim_attributes
  end

end