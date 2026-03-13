require 'rails_helper'

describe Shared::BiologicalAssociations do
  specify 'BIOLOGICALLY_RELATABLE_FACTORIES covers all biologically relatable types' do
    expect(BIOLOGICALLY_RELATABLE_FACTORIES.keys.sort).to eq(BIOLOGICALLY_RELATABLE_TYPES.sort)
  end
end
