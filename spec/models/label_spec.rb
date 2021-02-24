require 'rails_helper'

RSpec.describe Label, type: :model do

  let(:label) { Label.new }

  context 'validation' do

    specify 'label with no text is invalid' do
      expect(label.valid?).to be_falsey
    end

    specify 'label with text and total is valid' do
      label.text = 'This is some text'
      label.total = 0
      expect(label.valid?).to be_truthy
    end
  end

  specify '.unprinted' do
    expect(Label.unprinted).to contain_exactly()
  end

end
