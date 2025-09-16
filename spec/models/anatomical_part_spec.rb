require 'rails_helper'

RSpec.describe AnatomicalPart, type: :model do
  context 'validations' do
    specify 'name is valid' do
      a = AnatomicalPart.new(name: 'a')
      expect(a.valid?).to be_truthy
    end

    specify 'uri alone is not valid' do
      a = AnatomicalPart.new(uri: 'http://alo.ne')
      expect(a.valid?).to be_falsey
    end

    specify 'uri_label alone is not valid' do
      a = AnatomicalPart.new(uri_label: 'a')
      expect(a.valid?).to be_falsey
    end

    specify 'name or uri/label required' do
      a = AnatomicalPart.new
      expect(a.valid?).to be_falsey
    end

  end


end
