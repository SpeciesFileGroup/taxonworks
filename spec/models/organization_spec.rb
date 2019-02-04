require 'rails_helper'

RSpec.describe Organization, type: :model do

  let(:organization) { Organization.new }

  specify 'valid with name' do
    organization.name = 'My organization'
    expect(organization.valid?).to be_truthy
  end

  specify 'invalid without name' do
    expect(organization.valid?).to be_falsey
  end

end
