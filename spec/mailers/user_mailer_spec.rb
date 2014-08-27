require "rails_helper"

RSpec.describe UserMailer, :type => :mailer do
  let(:user) { FactoryGirl.create(:valid_user) }
  
  describe 'welcome_email' do
    let(:mail) { UserMailer.welcome_email(user) }
    subject = 'Welcome to TaxonWorks'
    
    it "sets the subject to \"#{subject}\"" do
      expect(mail.subject).to eq(subject)
    end
    
    it 'sets the recipient to the user\'s email address' do
      expect(mail.to).to eq([user.email])
    end
    
    it 'renders the sender email', skip: 'Need to figure out how to set up' do
      
    end
    
    it 'shows the user\'s e-mail address in the e-mail body' do
       expect(mail.body.encoded).to match(user.email)
    end
  end
  
  describe 'send_password_reset' do
    let(:mail) { UserMailer.password_reset_email(user, 'PASSWORD_TOKEN') }
    subject = 'Password reset request for TaxonWorks'
    
    it "sets the subject to \"#{subject}\"" do
      expect(mail.subject).to eq(subject)
    end

    it 'sets the recipient to the user\'s email address' do
      expect(mail.to).to eq([user.email])
    end
    
    it 'renders the sender email', skip: 'Need to figure out how to set up' do
      
    end

    it 'shows the user\'s e-mail address in the e-mail body' do
       expect(mail.body.encoded).to match(user.email)
    end
    
    it 'provides a password reset link in the e-mail body', skip: 'Cannot test URLs right yet' do
      expect(mail.body.encoded).to match(url_for(controller: 'users', action: 'password_reset', token: 'PASSWORD_TOKEN'))
    end
  end
  
end
