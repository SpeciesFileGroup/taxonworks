require 'rails_helper'

describe Settings do
  let(:valid_full_config) do
    { default_data_directory: 'tmp',
      exception_notification: {
        email_prefix: '[TW-Error] ',
        sender_address: %{"notifier" <notifier@example.com>},
        exception_recipients: ["exceptions@example.com"]
      } 
    }
  end
  let(:rails_config) {
    double('config', middleware: double('middleware'))
  }
        
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
                
        it "throws error when a setting is missing" do
          valid_config[:exception_notification].delete(:email_prefix)
          expect { Settings.load_from_hash(rails_config, valid_config) }.to raise_error(/.*\[\:email_prefix\].*/)
        end

        it "throws error when a setting is invalid" do
          valid_config[:exception_notification][:invalid_setting] = 'INVALID'
          expect { Settings.load_from_hash(rails_config, valid_config) }.to raise_error(/.*\[\:invalid_setting\].*/)
        end

        it "throws error when :exception_recipients is not an Array" do
          valid_config[:exception_notification][:exception_recipients] = 'NOT AN ARRAY'
          expect { Settings.load_from_hash(rails_config, valid_config) }.to raise_error(/.* Array*/) 
        end

      end
    
    end
    
    describe "default_data_directory" do
      
      context "when valid directory" do
        let(:valid_directory) { { default_data_directory: valid_full_config[:default_data_directory] } }
        
        it "sets ::default_data_directory to the absolute path of the supplied directory" do
          Settings.load_from_hash(rails_config, valid_directory)
          expect(Settings.default_data_directory).to eq(File.absolute_path(valid_directory[:default_data_directory]))
        end

      end
      
      context "when invalid directory" do
        
        it "throws error when directory does not exist" do
          invalid_directory = { default_data_directory: 'INVALID_DIRECTORY' }
          expect { Settings.load_from_hash(rails_config, invalid_directory) }.to raise_error(/.*INVALID_DIRECTORY.*/)
        end
        
        it "throws error when path is not a directory" do
          file = { default_data_directory: 'spec/settings/file' }
          expect { Settings.load_from_hash(rails_config, file) }.to raise_error(/.*spec\/settings\/file.*/)
        end
        
      end
      
      context "when not present" do
        
        it "sets ::default_data_directory to nil" do
          Settings.load_from_hash(rails_config, { })
          expect(Settings.default_data_directory).to eq(nil)
        end
        
      end
      
    end
    
    describe "invalid section" do
      let(:invalid_section_config) do
        { invalid_section: { } }  
      end
      
      it "throws error when a settings section is not valid" do
        expect { Settings.load_from_hash(rails_config, invalid_section_config) }.to raise_error(/.*invalid_section*/)
      end
      
    end
    
    describe "multiple sections" do
      
      it "loads all provided sections" do
        expect(rails_config.middleware).to receive(:use).with(ExceptionNotification::Rack, email: valid_config[:exception_notification])
        Settings.load_from_hash(rails_config, valid_full_config)
        expect(Settings.default_data_directory).to eq(File.absolute_path(valid_full_config[:default_data_directory]))
      end
      
    end
    
  end
  
  describe '::load_from_file' do
    
    it "calls ::load_from_hash with the supplied settings set in the YAML file converted to hash" do
      expect(Settings).to receive(:load_from_hash).with(rails_config, valid_full_config)
      Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml', :test)
    end
    
    it "calls ::load_from_hash with an empty hash when the settings set in the YAML file is empty" do
      expect(Settings).to receive(:load_from_hash).with(rails_config, { })
      Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml', :empty)
    end
    
    it "throws error when file not exists" do
      expect { Settings.load_from_file(rails_config, 'not_exists.yml', :test) }.to raise_error Errno::ENOENT
    end
    
    it "throws error when settings set is not present" do
      expect { Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml', :INVALID_SET_NAME) }.to raise_error(/.*INVALID_SET_NAME.*/)
    end
    
    it "throws error on syntax error" do
      expect { 
        Settings.load_from_file(rails_config, 'spec/files/settings/syntax_error.yml', :test) 
      }.to raise_error Psych::SyntaxError
    end
  end
  
end
