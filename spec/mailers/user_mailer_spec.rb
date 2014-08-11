require "rails_helper"

RSpec.describe UserMailer, :type => :mailer do
  
  let(:user) { User.new(password: 'password',
                        password_confirmation: 'password',
                        email: 'user@example.com')}
  let(:mail) { UserMailer.welcome_email(user) }
  
  describe 'welcome_email' do
    
    it 'sets the subject to "Welcome to TaxonWorks"' do
      expect(mail.subject).to eq('Welcome to TaxonWorks')
    end
    
    it 'sets the recipient to the user''s email address' do
      expect(mail.to).to eq([user.email])
    end
    
    skip 'renders the sender email'
    
    it 'shows the user''s email address in the body' do
       expect(mail.body.encoded).to match(user.email)
    end
    
  end
  
end
