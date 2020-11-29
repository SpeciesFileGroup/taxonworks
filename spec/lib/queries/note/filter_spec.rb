require 'rails_helper'

describe Queries::Note::Filter, type: :model do

  let(:otu) { Otu.create(name: 'Test') }
  let(:specimen) { Specimen.create! }
  let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }

  let!(:n1) { Note.create!(note_object: otu, text: "this is a note\non two lines") }
  let!(:n2) { Note.create!(note_object: specimen, text: "ooga booga") }
  let!(:n3) { Note.create!(note_object: collecting_event, text: "untold knowledge") }

  let(:query) { Queries::Note::Filter.new({}) }

  specify '#text' do
    query.text = 'ooga'
    expect(query.all.map(&:id)).to contain_exactly(n2.id)
  end

  specify '#note_object_id' do
    query.note_object_id = specimen.id
    expect(query.all.map(&:id)).to contain_exactly(n1.id, n2.id, n3.id)
  end

  specify '#note_object_type' do
    query.note_object_type = 'CollectionObject'
    expect(query.all.map(&:id)).to contain_exactly(n2.id)
  end

  specify '#object_global_id' do
    query.object_global_id = collecting_event.to_global_id.to_s 
    expect(query.all.map(&:id)).to contain_exactly(n3.id)
  end

end
