require 'rails_helper'

describe Identifier::Global::ZoologicalRecord, type: :model, group: :identifiers do
  let(:id) { Identifier::Global::ZoologicalRecord.new(identifier_object: FactoryBot.create(:valid_source)) }
  let(:id_on_person) { Identifier::Global::ZoologicalRecord.new(identifier_object: FactoryBot.create(:valid_person)) }

  specify 'matches "namespace" 1' do
    id.identifier = 'WOS:'
    id.valid?
    expect(id.errors.messages[:identifier]).to_not be_empty
  end

  specify 'matches "namespace" 2' do
    id.identifier = 'WOS:000355561500007'
    id.valid?
    expect(id.errors.messages[:identifier]).to_not be_empty
  end

  specify 'matches "namespace" 3' do
    id.identifier = 'ZOOREC:ZOOR15308052547'
    id.valid?
    expect(id.errors.messages[:identifier]).to be_empty
  end

  specify 'matches "namespace" 4' do
    id.identifier = 'PR123'
    id.valid?
    expect(id.errors.messages[:identifier]).to_not be_empty
  end

  specify 'only allowed on sources' do
    id_on_person.identifier = 'WOS:000355561500007'
    id_on_person.valid?
    expect(id_on_person.errors.full_messages[0]).to eq("Identifier object type is not a Source")
  end

  specify '#uri 1' do
    id.identifier = 'WOS:000355561500007'
    expect(id.uri).to eq('https://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcApp=Publons&SrcAuth=Publons_CEL&DestLinkType=FullRecord&DestApp=WOS_CPL&KeyUT=WOS:000355561500007')
  end

  specify '#uri 2' do
    id.identifier = 'ZOOREC:ZOOR15312084211'
    expect(id.uri).to eq('https://gateway.webofknowledge.com/gateway/Gateway.cgi?GWVersion=2&SrcApp=Publons&SrcAuth=Publons_CEL&DestLinkType=FullRecord&DestApp=WOS_CPL&KeyUT=ZOOREC:ZOOR15312084211')
  end

end
