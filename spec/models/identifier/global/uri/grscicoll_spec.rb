require 'rails_helper'

describe Identifier::Global::Uri::Grscicoll, type: :model, group: :identifiers do

  let(:id) { Identifier::Global::Uri::Grscicoll.new }

  let(:uri1) { 'http://grscicoll.org/institution/illinois-natural-history-survey' }
  let(:uri2) { 'http://grbio.org/institution/illinois-natural-history-survey' }
  let(:uri3) { 'http://biocol.org/urn:lsid:biocol.org:col:34797' }

  let(:repository) { FactoryBot.create(:valid_repository) }

  specify 'invalidly formed 1' do
    id.identifier_object = repository
    id.identifier = uri1.gsub('scicol', 'foo')
    expect(id.valid?).to be_falsey
  end

  specify 'invalidly formed 2' do
    id.identifier_object = repository
    id.identifier = uri2.gsub('grbio', 'foo')
    expect(id.valid?).to be_falsey
  end

  specify 'invalidly formed 3' do
    id.identifier_object = repository
    id.identifier = uri3.gsub('biocol', 'foo')
    expect(id.valid?).to be_falsey
  end

  specify 'valid on Repository' do
    id.identifier_object = repository
    id.identifier = uri1
    expect(id.valid?).to be_truthy
  end

  specify 'invalid on non-Repositories' do
    id.identifier_object = Specimen.create
    id.identifier = uri1
    expect(id.valid?).to be_falsey
  end

  specify 'valid form 2' do
    id.identifier_object = repository
    id.identifier = uri2
    expect(id.valid?).to be_truthy
  end

  specify 'valid form 3' do
    id.identifier_object = repository
    id.identifier = uri3
    expect(id.valid?).to be_truthy
  end

end
