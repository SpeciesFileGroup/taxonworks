require 'rails_helper'
describe Identifier::Global, type: :model, group: :identifiers do

  let!(:otu) { FactoryBot.create(:valid_otu) }
  let(:global_identifier) { Identifier::Global.new }

  specify 'community shared 1' do
    o = FactoryBot.create(:valid_otu)
    i = Identifier::Global::Uri.create!(identifier_object: o, identifier: 'http://abc.net/foo/1')
    expect(i.project_id.blank?).to be_falsey
  end

  specify 'community shared 2' do
    o = FactoryBot.create(:valid_source)
    i = Identifier::Global::Uri.create!(identifier_object: o, identifier: 'http://abc.net/foo/1')
    expect(i.project_id.blank?).to be_truthy
  end

  context 'validation' do
    before { global_identifier.valid? }

    specify 'only one global identifier *without* a relation is allowed per identifier type' do
      expect(otu.identifiers.create(type: 'Identifier::Global::Uri', identifier: 'http://abc.net/foo/1')).to be_truthy
      otu.reload
      i = otu.identifiers.new(type: 'Identifier::Global::Uri', identifier: 'http://abc.net/foo/2')
      expect(i.valid?).to be_falsey
      expect(i.errors.include?(:relation)).to be_truthy
    end

    specify 'more than one global identifier with a valid relation is allowed per identifier type' do
      expect(otu.identifiers << Identifier::Global::Uri.new(identifier: 'http://abc.net/bar/22')).to be_truthy
      otu.reload
      i = Identifier::Global::Uri.new(
        identifier: 'http://abc.net/bar/29',
        identifier_object: otu,
        relation: 'skos:closeMatch')
      expect(i.valid?).to be_truthy
    end

    specify 'second global identifier of same type with an invalid relation is not allowed' do
      expect(otu.identifiers << Identifier::Global::Uri.new(identifier: 'http://abc.net/bar/22')).to be_truthy
      otu.reload
      i = Identifier::Global::Uri.new(identifier: 'http://abc.net/bar/29', identifier_object: otu, relation: 'same_as')
      expect(i.valid?).to be_falsey
      expect(i.errors.include?(:relation)).to be_truthy
    end

    specify 'identifer is unique within project (same type)' do
      expect(otu.identifiers << Identifier::Global::Uri.new(identifier: 'http://abc.net/bar/22')).to be_truthy
      otu.reload
      i = Identifier::Global::Uri.new(
        identifier: 'http://abc.net/bar/22',
        identifier_object: otu,
        relation: 'skos:closeMatch')
      expect(i.valid?).to be_falsey
      expect(i.errors.include?(:identifier)).to be_truthy
    end

    # Complete after LSID validation is done
    # xspecify 'identifer is unique within project (different type)' do
    #   expect(otu.identifiers << Identifier::Global::Lsid.new(identifier: 'http://abc.net/bar/22')).to be_truthy
    #   otu.reload
    #   i = Identifier::Global::Uri.new(identifier: 'http://abc.net/bar/22', identifier_object: otu,  relation:
    # 'skos:closeMatch')
    #   expect(i.valid?).to be_falsey
    #   expect(i.errors.include?(:identifier)).to be_truthy
    # end

    specify 'same identifer is allowed b/w project (same type)' do
      id = 'http://abc.net/bar/22'
      expect(otu.identifiers << Identifier::Global::Uri.new(identifier: id)).to be_truthy
      p = FactoryBot.create(:valid_project, name: 'New Project')
      i = Identifier::Global::Uri.new(
        identifier: id,
        identifier_object: FactoryBot.create(:valid_otu, project_id: p.id),
        project_id: p.id)
      expect(i.valid?).to be_truthy
      expect(i.errors.include?(:identifier)).to be_falsey
    end

    specify 'namespace_id is nil' do
      global_identifier.namespace_id = FactoryBot.create(:valid_namespace).id
      global_identifier.valid?
      expect(global_identifier.errors.include?(:namespace_id)).to be_truthy
    end
  end

  specify 'cached is set' do
    id = 'http://abc.net/bar/22'
    i  = Identifier::Global::Uri.create!(identifier: id, identifier_object: Otu.create(name: 'aaa'))
    expect(i.reload.cached).to eq(id)
  end

  describe 'soft validation' do
    specify 'responding URI' do
      global_identifier.identifier = 'http://data.nhm.ac.uk/object/a9bdc16d-c9ba-4e32-9311-d5250af2b5ac'
      VCR.use_cassette('responding URI') do
        global_identifier.soft_validate(only_sets: [:resolved])
      end
      expect(global_identifier.soft_validations.messages_on(:identifier).empty?).to be_truthy
    end

    specify 'non-responding URI' do
      global_identifier.identifier = 'http://sandbox.speciesfile.org/object/a9bdc16d-c9ba-4e32-9311-d5250af2b5ac'
      VCR.use_cassette('non-responding URI') do
        global_identifier.soft_validate(only_sets: [:resolved])
      end
      expect(global_identifier.soft_validations.messages_on(:identifier).count).to eq(1)
    end
  end
end