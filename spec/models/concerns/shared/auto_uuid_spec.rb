require 'rails_helper'

describe 'AutoUuid', type: :model do

  let(:class_with_auto_uuid) {TestAutoUuid.new}

  specify 'creates Uuid' do
    class_with_auto_uuid.save!
    expect(Identifier::Global::Uuid::Auto.count).to eq(1)
  end

  specify 'does not create Uuid' do
    TestAutoUuid.create(
      identifiers_attributes: [
        { type: 'Identifier::Global::Uuid', 
          identifier: SecureRandom.uuid
        }
      ]
    )

    expect(Identifier::Global::Uuid::Auto.count).to eq(0)
    expect(Identifier::Global::Uuid.count).to eq(1)
  end

end

class TestAutoUuid < ApplicationRecord
  include FakeTable

  include Shared::Identifiers
  include Shared::AutoUuid

  include Housekeeping
end


