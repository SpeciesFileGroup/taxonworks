require 'rails_helper'
require 'application_enumeration'

describe 'ApplicationEnumeration' do

  let(:ae) { ApplicationEnumeration }

  specify '.data_models #2' do
    expect(ae.data_models).to include(Identifier)
  end

  specify '.data_models #1' do
    expect(ae.data_models).to include(AlternateValue)
  end

  specify '.data_models #3' do
    expect(ae.data_models).to include(TypeMaterial)
  end

end
