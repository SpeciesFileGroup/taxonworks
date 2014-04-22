require 'spec_helper'

describe User do

  let(:user) { User.new(password: 'password',
                        password_confirmation: 'password',
                        email: 'user_model@example.com')}

  subject { user }

  context 'associations' do
    context 'has_many' do
      specify 'projects' do
        expect(user.projects << Project.new()).to be_true
      end
    end
  end

  context 'with password, password confirmation and email' do
    it { should be_valid }
  end

  context 'when password is empty' do
    before { user.password = user.password_confirmation = '' }
    it { should be_invalid }
  end

  context 'when password confirmation doesn\'t match' do
    before { user.password_confirmation = 'mismatch' }
    it { should be_invalid }
  end

  context 'when password is too short' do
    before { user.password = user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  context 'when email is empty' do
    before { user.email = '' }
    it { should be_invalid }
  end

  context 'when email doesn\'t match expected format' do
    before { user.email = 'a b@c.d' }
    it { should be_invalid }
  end

  describe 'saved user' do
    pending 'password is only validated on .update() when both password and password_confirmation are provided'
  end

  describe 'remember token' do
    before { user.save }
    its(:remember_token) { should_not be_blank }
  end

end
