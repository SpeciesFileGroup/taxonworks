require 'rails_helper'

describe Shared::RandomTokenFields, :type => :model do
  let(:test_class) do
    Class.new do
      attr_accessor :foo_token, :foo_token_date, :test_token, :test_token_date

      include Shared::RandomTokenFields[:foo, :test]
    end
  end

  it "adds #generate_*_token and #*_token_matches? instance methods to model" do
    expect(test_class.instance_methods).to include(:generate_foo_token, :foo_token_matches?, :generate_test_token, :test_token_matches?)
  end

  describe "test token" do
    include_examples "random_token_methods" do
      subject { test_class.new }
      let(:token_name) { :test }
    end
  end
end
