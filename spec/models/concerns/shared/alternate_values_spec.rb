require 'rails_helper'

describe 'AlternateValues', :type => :model do
  let(:class_with_alternate_values) { TestAlternateValue.new } 

  context 'reflections / foreign keys' do
    specify 'has many alternates' do
      expect(class_with_alternate_values).to respond_to(:alternate_values)
      expect(class_with_alternate_values.alternate_values.count == 0).to be_truthy
    end
  end

  context 'methods' do
    specify 'has_alternate_values?' do
      expect(class_with_alternate_values).to respond_to(:has_alternate_values?)
      expect(class_with_alternate_values.has_alternate_values?).to be_falsey
    end 
  end
end

class TestAlternateValue < ActiveRecord::Base
  include FakeTable
  include Shared::AlternateValues
end


