require 'rails_helper'

describe Autoselect::Base, type: :model do

  # Minimal concrete subclass for testing
  let(:stub_level) do
    Class.new(Autoselect::Level) do
      def key = :smart
      def label = 'Smart'
      def description = 'stub'
      def call(term:, **) = []
    end
  end

  let(:test_autoselect_class) do
    level_klass = stub_level
    Class.new(Autoselect::Base) do
      define_method(:levels) { [level_klass.new] }
      def resource_path = '/test/autoselect'
      def response_values(record) = { test_id: record.id }
    end
  end

  let(:instance) { test_autoselect_class.new(project_id: 1) }

  describe 'config response (no term)' do
    let(:json) { instance.response }

    specify 'config key is populated' do
      expect(json[:config]).to be_a(Hash)
    end

    specify 'response is nil' do
      expect(json[:response]).to be_nil
    end

    specify 'map contains level keys as strings' do
      expect(json[:map]).to eq(['smart'])
    end

    specify 'levels array has metadata hashes' do
      expect(json[:levels]).to be_an(Array)
      expect(json[:levels].first).to have_key(:key)
    end

    specify 'operators array is present' do
      expect(json[:operators]).to be_an(Array)
    end

    specify 'user_preferences is empty hash' do
      expect(json[:user_preferences]).to eq({})
    end

    specify 'resource path is included' do
      expect(json[:resource]).to eq('/test/autoselect')
    end
  end

  describe 'term response' do
    let(:instance_with_term) do
      test_autoselect_class.new(term: 'Homo', level: 'smart', project_id: 1)
    end

    let(:json) { instance_with_term.response }

    specify 'response is an array' do
      expect(json[:response]).to be_an(Array)
    end

    specify 'config is nil' do
      expect(json[:config]).to be_nil
    end

    specify 'request echoes the term' do
      expect(json[:request][:term]).to eq('Homo')
    end

    specify 'level is present' do
      expect(json[:level]).to eq('smart')
    end
  end

  describe 'next_level escalation' do
    let(:fast_level) do
      Class.new(Autoselect::Level) do
        def key = :fast
        def label = 'Fast'
        def description = 'stub'
        def call(term:, **) = []
      end
    end

    let(:smart_level) do
      Class.new(Autoselect::Level) do
        def key = :smart
        def label = 'Smart'
        def description = 'stub'
        def call(term:, **) = []
      end
    end

    let(:two_level_class) do
      f = fast_level
      s = smart_level
      Class.new(Autoselect::Base) do
        define_method(:levels) { [f.new, s.new] }
        def resource_path = '/test/autoselect'
        def response_values(record) = {}
      end
    end

    specify 'empty fast result includes next_level: smart' do
      instance = two_level_class.new(term: 'ZZZ', level: 'fast', project_id: 1)
      json = instance.response
      expect(json[:next_level]).to eq('smart')
    end

    specify 'empty last level has no next_level' do
      instance = two_level_class.new(term: 'ZZZ', level: 'smart', project_id: 1)
      json = instance.response
      expect(json).not_to have_key(:next_level)
    end
  end

  describe 'abstract methods' do
    let(:bare_instance) { Autoselect::Base.new(term: 'Homo', level: 'smart', project_id: 1) }

    specify '#levels raises NotImplementedError' do
      expect { bare_instance.levels }.to raise_error(NotImplementedError)
    end

    specify '#response_values raises NotImplementedError' do
      expect { bare_instance.response_values(double) }.to raise_error(NotImplementedError)
    end

    specify '#resource_path raises NotImplementedError' do
      expect { bare_instance.resource_path }.to raise_error(NotImplementedError)
    end
  end

end
