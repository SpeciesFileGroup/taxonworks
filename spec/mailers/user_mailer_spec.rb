require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { FactoryBot.create(:valid_user) }

  describe 'welcome_email' do
    let(:mail) { UserMailer.welcome_email(user) }
    subject = 'Welcome to TaxonWorks'

    it "sets the subject to \"#{subject}\"" do
      expect(mail.subject).to eq(subject)
    end

    it 'sets the recipient to the user\'s email address' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders "TaxonWorks <noreply@#{Settings.mail_domain}>" as mail sender' do
      expect(mail.header[:from].value).to eq(['TaxonWorks <noreply@example.com>'])
    end

    it 'shows the user\'s e-mail address in the e-mail body' do
      expect(mail.body.encoded).to match(user.email)
    end
  end

  describe 'maintenance_email' do
    let(:mail) { UserMailer.maintenance_email("test message") }
    subject = 'TaxonWorks - Upcoming maintenance'

    it "sets the subject to \"#{subject}\"" do
      expect(mail.subject).to eq(subject)
    end

    it 'renders "TaxonWorks <noreply@#{Settings.mail_domain}>" as mail sender' do
      expect(mail.header[:from].value).to eq(['TaxonWorks <noreply@example.com>'])
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

    it 'renders "TaxonWorks <noreply@#{Settings.mail_domain}>" as mail sender' do
      expect(mail.header[:from].value).to eq(['TaxonWorks <noreply@example.com>'])
    end

    it 'shows the user\'s e-mail address in the e-mail body' do
      expect(mail.body.encoded).to match(user.email)
    end

    it 'provides a password reset link in the e-mail body' do
      expect(mail.body.encoded).to match(password_reset_url(token: 'PASSWORD_TOKEN'))
    end
  end

end
