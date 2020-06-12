require 'rails_helper'

RSpec.describe CrashTestController, type: :controller do
  describe '#index' do
    it 'crashes when visited' do
      expect { get(:index) }.to raise_error(ActiveRecord::RecordInvalid)
    end
     
  end
    
end
