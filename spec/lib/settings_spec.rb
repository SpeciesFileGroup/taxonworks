require 'rails_helper'

describe Settings do
  let(:valid_full_config) do
    { database_dumps_directory: 'tmp',
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
    let(:empty_config) { { } }

    describe 'exception_notification' do
            
      context 'when valid settings' do
      
        it 'sets up ExceptionNotification middleware with supplied config' do
          expect(rails_config.middleware).to receive(:use).with(ExceptionNotification::Rack, email: valid_config[:exception_notification])
          Settings.load_from_hash(rails_config, valid_config)
        end
        
        it 'does not set up ExceptionNotification middleware when no settings is available' do
          expect(rails_config.middleware).not_to receive(:use)
          Settings.load_from_hash(rails_config, empty_config)
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
    
    describe "database_dumps_directory" do
      
      context "when valid directory" do
        let(:valid_directory) { { database_dumps_directory: valid_full_config[:database_dumps_directory] } }
        
        it "sets ::db_dump_dir to the absolute path of the supplied directory" do
          Settings.load_from_hash(rails_config, valid_directory)
          expect(Settings.db_dumps_dir).to eq(File.absolute_path(valid_directory[:database_dumps_directory]))
        end
      end
      
      context "when invalid directory" do
        
        it "throws error when directory does not exist" do
          invalid_directory = { database_dumps_directory: 'INVALID_DIRECTORY' }
          expect { Settings.load_from_hash(rails_config, invalid_directory) }.to raise_error(/.*INVALID_DIRECTORY.*/)
        end
        
        it "throws error when path is not a directory" do
          file = { database_dumps_directory: 'spec/settings/file' }
          expect { Settings.load_from_hash(rails_config, file) }.to raise_error(/.*spec\/settings\/file.*/)
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
        expect(Settings.db_dumps_dir).to eq(File.absolute_path(valid_full_config[:database_dumps_directory]))
      end
      
    end
    
  end
  
  describe '::load_from_file' do
    
    it "calls ::load_from_hash with YAML file converted to hash" do
      expect(Settings).to receive(:load_from_hash).with(rails_config, valid_full_config)
      Settings.load_from_file(rails_config, 'spec/files/settings/valid.yml')
    end
    
    it "throws error when file not exists" do
      expect { Settings.load_from_file(rails_config, 'not_exists.yml') }.to raise_error
    end
    
    it "throws error on syntax error" do
      expect { 
        Settings.load_from_file(rails_config, 'spec/files/settings/syntax_error.yml') 
      }.to raise_error Psych::SyntaxError
    end
  end
  
end