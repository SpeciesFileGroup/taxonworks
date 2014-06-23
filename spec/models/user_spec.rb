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

  context 'authorization' do
    context 'when just a user' do
      specify '#is_administrator? is false' do
        expect(user.is_administrator?).to be_falsey  
      end

      specify '#is_project_administrator? is false' do
        expect(user.is_project_administrator?).to be_falsey
      end

      specify '#is_super_user?' do
        expect(user.is_superuser?).to be_falsey
      end
    end

    context 'when administator' do
      before { user.is_administrator = true  }
      specify '#is superuser?' do
        expect(user.is_superuser?).to be true
      end
    end

    context 'when project_administrator' do
      before { user.is_project_administrator = true  }
      specify '#is_superuser?' do
        expect(user.is_superuser?).to be true
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
    before { user.save }
    context 'password is not validated on .update() when neither password and password_confirmation are provided' do
      before { user.update(email: 'abc@def.com') }
      it {should be_valid}
      specify 'without errors' do
        expect(user.errors.count).to eq(0)
      end
    end

    context 'password is validated on .update() when password is provided' do
      before { user.update(password: 'Abcd123!') }
      it {should_not be_valid}
    end

    context 'password is validated on .update() when password is provided' do
      before { user.update(password_confirmation: 'Abcd123!') }
      it {should_not be_valid}
    end
  end

  describe 'remember token' do
    before { user.save }
    it(:remember_token) { should_not be_blank }
  end

end
