require 'rails_helper'

describe Shared::RandomTokenField, :type => :model do
  let(:test_class) do
    Class.new do
      attr_accessor :foo_token, :foo_token_date, :test_token, :test_token_date

      include Shared::RandomTokenField[:foo, :test]
    end
  end
  let(:subject) { test_class.new }
  
  it "adds #generate_*_token and #*_token_matches? instance methods to model" do
    expect(test_class.instance_methods).to include(:generate_foo_token, :foo_token_matches?, :generate_test_token, :test_token_matches?)
  end
  
  describe 'password reset token' do

    describe '#generate_test_token' do
      it 'records the time it was generated' do
        Timecop.freeze(DateTime.now) do
          subject.generate_test_token()
          expect(subject.test_token_date).to eq(DateTime.now)
        end
      end

      it 'generates a random token' do
        expect(subject.generate_test_token()).to_not eq(subject.generate_test_token())
      end

      it 'does not record the token in plain text' do
        token = subject.generate_test_token()
        expect(token).to_not eq(subject.test_token)
      end

      it 'generates the token with at least 16 chars' do
        expect(subject.generate_test_token).to satisfy { |v| v.length >= 16 }
      end
    end

    describe '#test_token_matches?' do

      context 'valid' do
        it 'returns truthy when the supplied token matches the subject' 's' do
          token = subject.generate_test_token()
          expect(subject.test_token_matches?(token)).to be_truthy
        end
      end

      context 'invalid' do
        let(:examples) { [nil, '', 'token'] }

        it 'returns falsey when the subject has no token' do
          subject.test_token = nil
          examples.each { |e| expect(subject.test_token_matches?(e)).to be_falsey }
        end

        it 'returns falsey when the supplied token does not match the subject' 's' do
          subject.generate_test_token()
          examples.each { |e| expect(subject.test_token_matches?(e)).to be_falsey }
        end
      end
    end
  end
end
