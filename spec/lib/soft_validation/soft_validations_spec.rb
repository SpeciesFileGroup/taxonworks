require 'rails_helper'
require 'lib/soft_validation_helpers'

describe 'SoftValidations', group: :soft_validation do
  let(:soft_validations) {SoftValidation::SoftValidations.new(Softy.new)}

  specify 'add' do
    expect(soft_validations).to respond_to(:add) 
  end

  specify 'add(:invalid_attribute, "message") raises' do
    expect{soft_validations.add(:foo, 'no cheezburgahz!')}.to raise_error(SoftValidation::SoftValidationError, /not a column name/)
  end

=begin
# We can't call these because of the `caller` hack and how it's hit from specs.  That's probably a sign about how bad it is.
  
specify '#size' do
    soft_validations.add(:base, 'no cheezburgahz!')
    expect(soft_validations.size).to eq(1)
  end

  specify 'add(:attribute, "message")' do
    expect(soft_validations.add(:base, 'no cheezburgahz!')).to be_truthy
    expect(soft_validations.soft_validations.count).to eq(1)
  end

  specify 'add(:attribute, "message", success_message: "win",  failure_message: "fail")' do
    expect(soft_validations.add(:base, 'no cheezburgahz!', success_message: 'haz cheezburger', failure_message: 'no cheezburger')).to be_truthy
  end
=end

  specify 'complete?' do
    soft_validations.validated = true 
    expect(soft_validations.complete?).to be_truthy
  end

  specify 'on' do
    expect(soft_validations).to respond_to(:on)
    expect(soft_validations.on(:base)).to eq([])
  end

  specify 'messages' do
    expect(soft_validations).to respond_to(:messages)
  end

  specify 'messages_on' do
    expect(soft_validations).to respond_to(:messages)
  end

  specify '#resolution_for' do
    expect(soft_validations).to respond_to(:resolution_for)
  end

  specify '#validated?' do
    expect(soft_validations.validated?).to eq(false)
  end 

  specify '#fixes_run?' do
    expect(soft_validations.fixes_run?).to eq(false)
  end 

  specify '#complete?' do
    expect(soft_validations.complete?).to eq(false)
  end 

  specify '#fix_messages' do
    expect(soft_validations.fix_messages).to eq({})
  end 
 
end

