require 'rails_helper'

describe Autoselect::Operators do

  let(:test_class) do
    Class.new do
      include Autoselect::Operators
    end
  end

  let(:instance) { test_class.new }

  describe '#parse_operators' do
    specify 'extracts !r (recent) operator and strips prefix' do
      result = instance.parse_operators('!r Homo')
      expect(result[:operator]).to eq(:recent)
      expect(result[:effective_term]).to eq('Homo')
    end

    specify '!rm (recent_mine) is matched before !r' do
      result = instance.parse_operators('!rm Homo')
      expect(result[:operator]).to eq(:recent_mine)
      expect(result[:effective_term]).to eq('Homo')
    end

    specify '!? (help) is extracted' do
      result = instance.parse_operators('!?')
      expect(result[:operator]).to eq(:help)
      expect(result[:effective_term]).to eq('')
    end

    specify '!n (new_record) is extracted' do
      result = instance.parse_operators('!n Foobar')
      expect(result[:operator]).to eq(:new_record)
      expect(result[:effective_term]).to eq('Foobar')
    end

    specify '!# (level_hash) is extracted' do
      result = instance.parse_operators('!# Foobar')
      expect(result[:operator]).to eq(:level_hash)
      expect(result[:effective_term]).to eq('Foobar')
    end

    specify '!1 (level_number) is extracted' do
      result = instance.parse_operators('!1 Homo')
      expect(result[:operator]).to eq(:level_number)
      expect(result[:effective_term]).to eq('Homo')
    end

    specify 'no operator returns nil operator and full string as effective_term' do
      result = instance.parse_operators('Homo sapiens')
      expect(result[:operator]).to be_nil
      expect(result[:effective_term]).to eq('Homo sapiens')
    end

    specify 'blank term returns nil operator and empty effective_term' do
      result = instance.parse_operators('')
      expect(result[:operator]).to be_nil
      expect(result[:effective_term]).to eq('')
    end

    specify 'nil term returns nil operator and empty effective_term' do
      result = instance.parse_operators(nil)
      expect(result[:operator]).to be_nil
      expect(result[:effective_term]).to eq('')
    end

    specify 'effective_term is stripped of leading whitespace' do
      result = instance.parse_operators('!r   Homo')
      expect(result[:effective_term]).to eq('Homo')
    end
  end

  describe '.operator_definitions' do
    let(:definitions) { test_class.operator_definitions }

    specify 'returns an array' do
      expect(definitions).to be_an(Array)
    end

    specify 'each definition has key, trigger, description, client_only' do
      definitions.each do |d|
        expect(d).to have_key(:key)
        expect(d).to have_key(:trigger)
        expect(d).to have_key(:description)
        expect(d).to have_key(:client_only)
      end
    end

    specify 'key values are strings' do
      definitions.each do |d|
        expect(d[:key]).to be_a(String)
      end
    end

    specify 'client_only is boolean' do
      definitions.each do |d|
        expect(d[:client_only]).to be(true).or be(false)
      end
    end

    specify 'level_hash and level_number are client_only' do
      client_only = definitions.select { |d| d[:client_only] }.map { |d| d[:key] }
      expect(client_only).to include('level_hash', 'level_number')
    end

    specify 'recent, recent_mine, help, new_record are not client_only' do
      server_side = definitions.reject { |d| d[:client_only] }.map { |d| d[:key] }
      expect(server_side).to include('recent', 'recent_mine', 'help', 'new_record')
    end
  end

  describe '.operator_map' do
    specify 'returns the default OPERATORS hash' do
      expect(test_class.operator_map).to eq(Autoselect::Operators::OPERATORS)
    end
  end

end
