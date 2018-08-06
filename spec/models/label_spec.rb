require 'rails_helper'

RSpec.describe Label, type: :model do

  let(:label) { Label.new }

  context 'validation' do

    specify 'label with text is invalid' do
      expect(label.valid?).to be_falsey
    end

    specify 'label with text is valid' do
      label.text = 'This is some text'
      expect(label.valid?).to be_truthy
    end
  end


  specify '.unprinted' do
    expect(Label.unprinted).to contain_exactly()
  end





end
