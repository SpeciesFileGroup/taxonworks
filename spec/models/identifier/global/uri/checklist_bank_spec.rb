require 'rails_helper'

describe Identifier::Global::Uri::ChecklistBank, type: :model, group: :identifiers do

  let(:taxon_name) { FactoryBot.build(:valid_taxon_name) }
  let(:otu)        { FactoryBot.build(:valid_otu) }

  let(:valid_uri)  { 'https://api.checklistbank.org/dataset/9802/taxon/1000027' }
  let(:string_ids) { 'https://api.checklistbank.org/dataset/3LR/taxon/abc-99' }

  let(:id) { Identifier::Global::Uri::ChecklistBank.new(identifier_object: taxon_name) }

  # ── used_on_taxon_name_or_otu ───────────────────────────────────────────────

  describe 'validation: used_on_taxon_name_or_otu' do
    specify 'valid when used on a TaxonName' do
      id.identifier = valid_uri
      expect(id.valid?).to be_truthy
    end

    specify 'valid when used on an OTU' do
      id.identifier_object = otu
      id.identifier = valid_uri
      expect(id.valid?).to be_truthy
    end

    specify 'invalid on any other object type' do
      id.identifier_object = FactoryBot.build(:valid_source_bibtex)
      id.identifier = valid_uri
      expect(id.valid?).to be_falsey
      expect(id.errors[:identifier_object_type]).to be_present
    end
  end

  # ── path_format ─────────────────────────────────────────────────────────────

  describe 'validation: path_format' do
    specify 'valid when path contains dataset/<id>/taxon/<id>' do
      id.identifier = valid_uri
      expect(id.valid?).to be_truthy
    end

    specify 'invalid when dataset segment is missing' do
      id.identifier = 'https://api.checklistbank.org/taxon/1000027'
      expect(id.valid?).to be_falsey
      expect(id.errors[:identifier]).to be_present
    end

    specify 'invalid when taxon segment is missing' do
      id.identifier = 'https://api.checklistbank.org/dataset/9802'
      expect(id.valid?).to be_falsey
      expect(id.errors[:identifier]).to be_present
    end

    specify 'invalid when path is absent entirely' do
      id.identifier = 'https://api.checklistbank.org'
      expect(id.valid?).to be_falsey
      expect(id.errors[:identifier]).to be_present
    end
  end

  # ── dataset_id ───────────────────────────────────────────────────────────────

  describe '#dataset_id' do
    specify 'returns the dataset segment for an integer id' do
      id.identifier = valid_uri
      expect(id.dataset_id).to eq('9802')
    end

    specify 'returns the dataset segment for a non-integer id' do
      id.identifier = string_ids
      expect(id.dataset_id).to eq('3LR')
    end
  end

  # ── taxon_id ─────────────────────────────────────────────────────────────────

  describe '#taxon_id' do
    specify 'returns the taxon segment for an integer id' do
      id.identifier = valid_uri
      expect(id.taxon_id).to eq('1000027')
    end

    specify 'returns the taxon segment for a non-integer id' do
      id.identifier = string_ids
      expect(id.taxon_id).to eq('abc-99')
    end
  end

  # ── api_format ───────────────────────────────────────────────────────────────

  describe '#api_format' do
    specify 'returns a well-formed API URL from the API root' do
      id.identifier = valid_uri
      expect(id.api_format).to eq('https://api.checklistbank.org/dataset/9802/taxon/1000027')
    end

    specify 'normalises a www-rooted identifier to the API root' do
      id.identifier = 'https://www.checklistbank.org/dataset/9802/taxon/1000027'
      expect(id.api_format).to eq('https://api.checklistbank.org/dataset/9802/taxon/1000027')
    end
  end

  # ── virtual setters (dataset_id=, taxon_id=) ─────────────────────────────────

  describe 'virtual setters' do
    describe 'set_identifier callback' do
      specify 'constructs identifier from dataset_id and taxon_id before validation' do
        id.dataset_id = '9802'
        id.taxon_id   = '1000027'
        id.valid?
        expect(id.identifier).to eq('https://api.checklistbank.org/dataset/9802/taxon/1000027')
      end

      specify 'produces a valid record when both virtual attributes are set' do
        id.dataset_id = '9802'
        id.taxon_id   = '1000027'
        expect(id.valid?).to be_truthy
      end

      specify 'works with non-integer ids' do
        id.dataset_id = '3LR'
        id.taxon_id   = 'abc-99'
        id.valid?
        expect(id.identifier).to eq('https://api.checklistbank.org/dataset/3LR/taxon/abc-99')
      end
    end

    describe '#dataset_id getter' do
      specify 'returns the virtual value when set via setter' do
        id.dataset_id = '9802'
        expect(id.dataset_id).to eq('9802')
      end
    end

    describe '#taxon_id getter' do
      specify 'returns the virtual value when set via setter' do
        id.taxon_id = '1000027'
        expect(id.taxon_id).to eq('1000027')
      end
    end
  end

end
