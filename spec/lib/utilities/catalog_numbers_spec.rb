require 'rails_helper'

describe Utilities::CatalogNumbers do
  let(:l) { Utilities::CatalogNumbers }

  context '.parse without priors' do
    specify 'blank is nil' do
      expect(l.parse(nil)).to be_nil
      expect(l.parse('  ')).to be_nil
    end

    specify 'space delimited' do
      expect(l.parse('INHS 122345')).to include(namespace: 'INHS', identifier: '122345', delimiter: ' ', prior: nil)
    end

    specify 'no delimiter' do
      expect(l.parse('USNMENT00123456')).to include(namespace: 'USNMENT', identifier: '00123456', delimiter: '')
    end

    specify 'multi-part namespace' do
      expect(l.parse('MCZ:ENT:12345')).to include(namespace: 'MCZ:ENT', identifier: '12345', delimiter: ':')
    end

    specify 'multi-word namespace' do
      expect(l.parse('INHS Insect Collection 12345')).to include(namespace: 'INHS Insect Collection', identifier: '12345')
    end

    specify 'identifier with trailing letters and punctuation' do
      expect(l.parse('INHS 123-45a')).to include(namespace: 'INHS', identifier: '123-45a')
    end

    specify 'surrounding whitespace is stripped' do
      expect(l.parse("  INHS 1 \n")).to include(namespace: 'INHS', identifier: '1')
    end

    specify 'only an identifier' do
      expect(l.parse('122345')).to include(namespace: nil, identifier: '122345', delimiter: nil)
    end

    specify 'no digits, no prediction' do
      expect(l.parse('INHS')).to include(namespace: nil, identifier: 'INHS')
    end
  end

  context '.parse with priors' do
    specify 'a prior is matched' do
      expect(l.parse('INHS 122345', namespaces: ['INHS'])).to include(namespace: 'INHS', identifier: '122345', prior: 'INHS')
    end

    specify 'matching is case insensitive, the string is preserved' do
      expect(l.parse('inhs-122345', namespaces: ['INHS'])).to include(namespace: 'inhs', identifier: '122345', delimiter: '-', prior: 'INHS')
    end

    specify 'the longest prior wins' do
      expect(l.parse('INHS Ins 12', namespaces: ['INHS', 'INHS Ins'])).to include(prior: 'INHS Ins', identifier: '12')
    end

    specify 'a prior does not match part of a word' do
      expect(l.parse('INHSX 12', namespaces: ['INHS'])).to include(namespace: 'INHSX', prior: nil)
    end

    specify 'a prior containing digits' do
      expect(l.parse('SEMC2 0001', namespaces: ['SEMC2'])).to include(namespace: 'SEMC2', identifier: '0001', prior: 'SEMC2')
    end

    specify 'a prior without delimiter' do
      expect(l.parse('INHS0001', namespaces: ['INHS'])).to include(namespace: 'INHS', identifier: '0001', delimiter: '', prior: 'INHS')
    end

    specify 'a prior with nothing following does not match' do
      expect(l.parse('INHS', namespaces: ['INHS'])).to include(namespace: nil, identifier: 'INHS', prior: nil)
    end

    specify 'blank priors are ignored' do
      expect(l.parse('INHS 1', namespaces: [nil, '', 'INHS'])).to include(prior: 'INHS')
    end

    specify 'no prior matches, falls back to prediction' do
      expect(l.parse('FMNH 1', namespaces: ['INHS'])).to include(namespace: 'FMNH', identifier: '1', prior: nil)
    end

    specify 'a repeated namespace is removed once' do
      expect(l.parse('INHS INHS 1', namespaces: ['INHS'])).to include(namespace: 'INHS', identifier: 'INHS 1')
    end
  end

  context '.identifier' do
    specify 'strips a matched prior' do
      expect(l.identifier('INHS 122345', namespaces: ['INHS'])).to eq('122345')
    end

    specify 'returns the whole string when no prior matches' do
      expect(l.identifier('FMNH 1', namespaces: ['INHS'])).to eq('FMNH 1')
    end

    specify 'returns the whole string when no priors are given' do
      expect(l.identifier('FMNH 1')).to eq('FMNH 1')
    end
  end
end
