require 'rails_helper'

describe Autoselect::Response do

  let(:config_hash) do
    {
      resource: '/test/autoselect',
      levels: [],
      operators: [],
      map: ['smart'],
      user_preferences: {}
    }
  end

  let(:sample_item) do
    { id: 1, label: 'Homo', label_html: '<em>Homo</em>', info: nil, response_values: { test_id: 1 }, extension: {} }
  end

  describe 'config response (no term)' do
    let(:response) do
      Autoselect::Response.new(
        config: config_hash,
        request: nil,
        level: nil,
        results: nil,
        next_level: nil,
        level_map: ['smart']
      )
    end

    let(:json) { response.as_json }

    specify 'config key is populated' do
      expect(json[:config]).to be_a(Hash)
    end

    specify 'response key is nil' do
      expect(json[:response]).to be_nil
    end

    specify 'top-level resource is present' do
      expect(json[:resource]).to eq('/test/autoselect')
    end

    specify 'top-level map is present' do
      expect(json[:map]).to eq(['smart'])
    end

    specify 'user_preferences is included' do
      expect(json[:user_preferences]).to eq({})
    end
  end

  describe 'term response with results' do
    let(:response) do
      Autoselect::Response.new(
        config: nil,
        request: { term: 'Homo', level: 'smart', project_id: 1 },
        level: 'smart',
        results: [sample_item],
        next_level: nil,
        level_map: nil
      )
    end

    let(:json) { response.as_json }

    specify 'response is an array' do
      expect(json[:response]).to be_an(Array)
    end

    specify 'config is nil' do
      expect(json[:config]).to be_nil
    end

    specify 'request is echoed' do
      expect(json[:request][:term]).to eq('Homo')
    end

    specify 'level is present' do
      expect(json[:level]).to eq('smart')
    end

    specify 'next_level is NOT present when results are non-empty' do
      expect(json).not_to have_key(:next_level)
    end
  end

  describe 'term response with empty results' do
    let(:response) do
      Autoselect::Response.new(
        config: nil,
        request: { term: 'ZZZ', level: 'fast', project_id: 1 },
        level: 'fast',
        results: [],
        next_level: 'smart',
        level_map: nil
      )
    end

    let(:json) { response.as_json }

    specify 'response is an empty array' do
      expect(json[:response]).to eq([])
    end

    specify 'next_level is present' do
      expect(json[:next_level]).to eq('smart')
    end
  end

  describe 'term response with nil next_level' do
    let(:response) do
      Autoselect::Response.new(
        config: nil,
        request: { term: 'ZZZ', level: 'smart', project_id: 1 },
        level: 'smart',
        results: [],
        next_level: nil,
        level_map: nil
      )
    end

    specify 'next_level key is absent when nil' do
      expect(response.as_json).not_to have_key(:next_level)
    end
  end

end
