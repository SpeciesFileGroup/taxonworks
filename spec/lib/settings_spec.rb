require 'rails_helper'

describe Settings do
  before(:all) { @current_settings_hash = Settings.get_config_hash }

  let(:valid_full_config) do
    { default_data_directory: 'tmp',
      backup_directory: 'tmp',
      exception_notification: {
        email_prefix: '[TW-Error] ',
        sender_address: %{"notifier" <notifier@example.com>},
        exception_recipients: 'exceptions@example.com,other_exceptions@example.com'
      }
    }
  end

  let(:rails_config) {
    double(
      'config',
      middleware: double('middleware'),
      action_mailer: double('action_mailer'),
    )
  }

  after(:all) do
    current_settings_hash =  Settings.get_config_hash
    config = {
      default_data_directory: current_settings_hash[:default_data_directory],
      backup_directory: current_settings_hash[:backup_directory],
      mail_domain: current_settings_hash[:mail_domain],
    }
    Settings.load_from_hash({}, config)
  end

  describe '::load_from_hash' do
    let(:valid_config) { { exception_notification: valid_full_config[:exception_notification] } }

    describe 'exception_notification' do

      context 'when valid settings' do
        it 'sets up ExceptionNotification middleware with supplied config' do
          expect(rails_config.middleware).to receive(:use).with(ExceptionNotification::Rack, email: valid_config[:exception_notification])
          Settings.load_from_hash(rails_config, valid_config)
        end

        it 'does not set up ExceptionNotification middleware when no settings is available' do
          expect(rails_config.middleware).not_to receive(:use)
          Settings.load_from_hash(rails_config, { })
        end
      end

      context 'when invalid settings' do
        it 'throws error when a setting is missing' do
          valid_config[:exception_notification].delete(:email_prefix)
          expect { Settings.load_from_hash(rails_config, valid_config) }.to raise_error(Settings::Error, /.*\[\:email_prefix\].*/)
        end

        it 'throws error when a setting is invalid' do
          valid_config[:exception_notification][:invalid_setting] = 'INVALID'
          expect { Settings.load_from_hash(rails_config, valid_config) }.to raise_error(Settings::Error, /.*\[\:invalid_setting\].*/)
        end
      end
    end

    describe 'default_data_directory' do
      context 'when valid directory' do
        let(:valid_directory) { {default_data_directory: valid_full_config[:default_data_directory]} }

        it 'sets ::default_data_directory to the absolute path of the supplied directory' do
          Settings.load_from_hash(rails_config, valid_directory)
          expect(Settings.default_data_directory).to eq(File.absolute_path(valid_directory[:default_data_directory]))
        end

      end

      context 'when uncreated directory' do
        let(:path) { File.absolute_path('DATA_INVALID_DIRECTORY') }
        let(:invalid_directory) { {default_data_directory: path} }

        after(:all) { FileUtils.rm_rf(File.absolute_path('DATA_INVALID_DIRECTORY')) }

        it 'creates the directory when it does not exist' do
          expect(Settings.load_from_hash(rails_config, invalid_directory)).to be_truthy
          expect(Dir.exists?(path)).to be_truthy
        end
      end

      context 'when not present' do
        it 'sets ::default_data_directory to nil' do
          Settings.load_from_hash(rails_config, {})
          expect(Settings.default_data_directory).to eq(nil)
        end
      end
    end

    describe 'exception_recipients' do
      let(:valid_exception_notification) {
        { exception_recipients: valid_full_config[:exception_notification][:exception_recipients],
          email_prefix: 'foo',
          sender_address: 'bar'
      }
      }

      context 'is parsed into an array' do
        it 'sets ::exception_recipients splitting on comma' do
          expect(Settings.send(:process_exception_notification, valid_exception_notification)[:exception_recipients]).to eq(valid_full_config[:exception_notification][:exception_recipients].split(',') )
        end
      end
    end

    describe 'backup_directory' do
      context 'when valid directory' do
        let(:valid_directory) { { backup_directory: valid_full_config[:backup_directory] } }

        it 'sets ::backup_directory to the absolute path of the supplied directory' do
          Settings.load_from_hash(rails_config, valid_directory)
          expect(Settings.backup_directory).to eq(File.absolute_path(valid_directory[:backup_directory]))
        end

      end

      context 'when uncreated directory' do
        let(:path) { File.absolute_path('INVALID_DIRECTORY') }
        let(:invalid_directory) { { backup_directory: path } }

        after(:all) { FileUtils.rm_rf( File.absolute_path('INVALID_DIRECTORY') ) }

        it 'creates the directory when it does not exist' do
          expect(Settings.load_from_hash(rails_config, invalid_directory)).to be_truthy
          expect( Dir.exists?(path) ).to be_truthy
        end
      end

      context 'when not present' do
        it 'sets ::backup_directory to nil' do
          Settings.load_from_hash(rails_config, { })
          expect(Settings.backup_directory).to eq(nil)
        end
      end

    end


    describe 'action_mailer_smtp_settings' do

      context 'when valid settings' do
        let(:valid_smtp) {
          { action_mailer_smtp_settings: { address: 'smtp.example.com', port: 25, domain: 'example.com' } }
        }

        it 'sets ActionMailer delivery method to SMTP with supplied config' do
          expect(rails_config.action_mailer).to receive('delivery_method=').with(:smtp)
          expect(rails_config.action_mailer).to receive('smtp_settings=').with(
            {openssl_verify_mode: 'none'}.merge(valid_smtp[:action_mailer_smtp_settings])
          )
          Settings.load_from_hash(rails_config, valid_smtp)
        end

      end

      context 'when not present' do
        it 'does not alter ActionMailer settings' do
          expect(rails_config.action_mailer).not_to receive('delivery_method=')
          Settings.load_from_hash(rails_config, { })
        end
      end

    end

    describe 'action_mailer_url_host' do

      context 'present' do
        let(:host) { { action_mailer_url_host: 'example.com' } }

        it 'sets up ActionMailer default URL host with the supplied config' do
          expect(rails_config.action_mailer).to receive('default_url_options=').with({ host: 'example.com' })
          Settings.load_from_hash(rails_config, host)
        end
      end

      context 'when not present' do
        it 'does not alter ActionMailer settings' do
          expect(rails_config.action_mailer).not_to receive('default_url_options=')
          Settings.load_from_hash(rails_config, { })
        end
      end

    end

    describe 'mail_domain' do

      context 'present' do
        let(:host) { { mail_domain: 'example.com' } }

        it 'sets ::mail_domain with the supplied domain' do
          Settings.load_from_hash(rails_config, host)
          expect(Settings.mail_domain).to eq('example.com')
        end
      end

      context 'when not present' do
        it 'sets ::mail_domain to nil' do
          Settings.load_from_hash(rails_config, { })
          expect(Settings.mail_domain).to be_nil
        end
      end

    end

    describe 'capistrano' do
      it 'accepts a capistrano section' do
        expect { Settings.load_from_hash(rails_config, { capistrano: { } }) }.to_not raise_error
      end
    end

    describe 'invalid section' do
      let(:invalid_section_config) do
        { invalid_section: { } }
      end

      it 'throws error when a settings section is not valid' do
        expect { Settings.load_from_hash(rails_config, invalid_section_config) }.to raise_error(/.*invalid_section*/)
      end

    end

    describe 'multiple sections' do

      it 'loads all provided sections' do
        expect(rails_config.middleware).to receive(:use).with(ExceptionNotification::Rack, email: valid_config[:exception_notification])
        Settings.load_from_hash(rails_config, valid_full_config)
        expect(Settings.default_data_directory).to eq(File.absolute_path(valid_full_config[:default_data_directory]))
      end

    end

  end

  describe '::get_config_hash' do
    let(:config) { { mail_domain: 'example.com' } }
    it 'returns the latest config hash used' do
      Settings.load_from_hash(rails_config, config)
      expect(Settings.get_config_hash).to eq(config)
    end
  end

  describe '::load_from_file' do

    it 'calls ::load_from_hash with the supplied settings set in the YAML file converted to hash' do
      expect(Settings).to receive(:load_from_hash).with(rails_config, valid_full_config)
      Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml', :test)
    end

    it 'calls ::load_from_hash with an empty hash when the settings set in the YAML file is empty' do
      expect(Settings).to receive(:load_from_hash).with(rails_config, { })
      Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml', :empty)
    end

    it 'throws error when file not exists' do
      expect { Settings.load_from_file(rails_config, 'not_exists.yml', :test) }.to raise_error Errno::ENOENT
    end

    it 'throws error when settings set is not present' do
      expect { Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml', :INVALID_SET_NAME) }.to raise_error(/.*INVALID_SET_NAME.*/)
    end

    it 'throws error on syntax error' do
      expect {
        Settings.load_from_file(rails_config, 'spec/files/settings/syntax_error.yml', :test)
      }.to raise_error Psych::SyntaxError
    end
  end

  describe '::load_from_settings_file' do

    it 'calls ::load_from_file using config/application_settings.yml if exists' do
      allow(File).to receive(:exist?).with('config/application_settings.yml').and_return(true)

      expect(Settings).to receive(:load_from_file).with(rails_config, 'config/application_settings.yml', :test)
      Settings.load_from_settings_file(rails_config, :test)
    end

    it 'does not call ::load_from_file if config/application_settings.yml does not exist' do
      allow(File).to receive(:exist?).with('config/application_settings.yml').and_return(false)

      expect(Settings).not_to receive(:load_from_file)
      Settings.load_from_settings_file(rails_config, :test)
    end
  end

end
