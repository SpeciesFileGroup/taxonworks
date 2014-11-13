require 'rails_helper'

describe Configuration do
  let(:valid_config) do
    { exception_notification: {
        email_prefix: '[TW-Error] ',
        sender_address: %{"notifier" <notifier@example.com>},
        exception_recipients: ["exceptions@example.com"]
      } 
    }
  end
  let(:rails_config) {
    double('config', middleware: double('middleware'))
  }
        
  describe '#load_from_hash' do
    let(:empty_config) { { } }

    describe 'exception_notification' do
            
      context 'when valid configuration' do
      
        it 'sets up ExceptionNotification middleware with supplied config' do
          expect(rails_config.middleware).to receive(:use).with(ExceptionNotification::Rack, email: valid_config[:exception_notification])
          Configuration.load_from_hash(rails_config, valid_config)
        end
        
        it 'does not set up ExceptionNotification middleware when no configuration is available' do
          expect(rails_config.middleware).not_to receive(:use)
          Configuration.load_from_hash(rails_config, empty_config)
        end
      
      end
    
      context 'when invalid configuration' do  
                
        it "throws error when a setting is missing" do
          valid_config[:exception_notification].delete(:email_prefix)
          expect { Configuration.load_from_hash(rails_config, valid_config) }.to raise_error(/.*\[\:email_prefix\].*/)
        end
        
        it "throws error when a setting is invalid" do
          valid_config[:exception_notification][:invalid_setting] = 'INVALID'
          expect { Configuration.load_from_hash(rails_config, valid_config) }.to raise_error(/.*\[\:invalid_setting\].*/)
        end
        
        it "throws error when :exception_recipients is not an Array" do
          valid_config[:exception_notification][:exception_recipients] = 'NOT AN ARRAY'
          expect { Configuration.load_from_hash(rails_config, valid_config) }.to raise_error(/.* Array*/) 
        end
      
      end
    
    end
    
    describe "invalid section" do
      let(:invalid_section_config) do
        { invalid_section: { } }  
      end
      
      it "throws error when a configuration section is not valid" do
        expect { Configuration.load_from_hash(rails_config, invalid_section_config) }.to raise_error(/.*invalid_section*/)
      end
      
    end
    
  end
  
  describe '#load_from_file' do
    
    it "calls #load_from_hash with YAML file converted to hash" do
      expect(Configuration).to receive(:load_from_hash).with(rails_config, valid_config)
      Configuration.load_from_file(rails_config, Rails.root + 'spec/files/configuration/valid.yml')
    end
    
    it "throws error when file not exists" do
      expect { Configuration.load_from_file(rails_config, 'not_exists.yml') }.to raise_error
    end
    
    it "throws error on syntax error" do
      expect { 
        Configuration.load_from_file(rails_config, Rails.root + 'spec/files/configuration/syntax_error.yml') 
      }.to raise_error Psych::SyntaxError
    end
  end
  
end