require 'spec_helper'

describe User do

  let(:user) { User.new password: 'password',
               password_confirmation: 'password',
               email: 'user@example.com'}

  subject { user }

  it { should be_valid }

  describe "when password is not present" do
    before do
      user.password = user.password_confirmation = ' '
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "when email is not present" do
    before { user.email = '' }
    it { should be_invalid }
  end

  describe "when email doesn't match expected format" do
    before { user.email = 'a b@c.d' }
    it { should be_invalid }
  end

  context 'factory valid_user is valid' do
    let(:factory_user) {
      FactoryGirl.build(:valid_user)
    }
    specify 'is valid' do
      expect(factory_user.valid?).to be_true
    end 
  end

end
