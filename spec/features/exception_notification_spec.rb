require 'rails_helper'

describe 'Exception notification', :type => :feature do
  before { ActionMailer::Base.deliveries.clear }
  
  it 'sends an email when an exception occurs' do
    (visit crash_test_path) rescue nil 
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end
  
end

