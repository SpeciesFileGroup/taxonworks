require 'rails_helper'

describe Autoselect::Level, type: :model do

  let(:concrete_level) do
    Class.new(Autoselect::Level) do
      def key = :test
      def label = 'Test'
      def description = 'A test level'
      def call(term:, **) = []
    end
  end

  let(:instance) { concrete_level.new }

  specify '#metadata has required keys' do
    m = instance.metadata
    expect(m.keys).to include(:key, :label, :description, :external, :fuse_ms)
  end

  specify '#metadata key is a string' do
    expect(instance.metadata[:key]).to eq('test')
  end

  specify '#external? is false by default' do
    expect(instance.external?).to be false
  end

  specify '#fuse_ms defaults to DEFAULT_FUSE_MS (600)' do
    expect(instance.fuse_ms).to eq(Autoselect::Level::DEFAULT_FUSE_MS)
  end

  specify 'external level has fuse_ms equal to EXTERNAL_FUSE_MS (2000)' do
    external_level = Class.new(concrete_level) do
      def external? = true
    end
    expect(external_level.new.fuse_ms).to eq(Autoselect::Level::EXTERNAL_FUSE_MS)
  end

  specify '#minimum_results is 1 by default' do
    expect(instance.minimum_results).to eq(1)
  end

  specify 'abstract methods raise NotImplementedError' do
    abstract = Autoselect::Level.new
    expect { abstract.key }.to raise_error(NotImplementedError)
    expect { abstract.label }.to raise_error(NotImplementedError)
    expect { abstract.description }.to raise_error(NotImplementedError)
    expect { abstract.call(term: 'foo') }.to raise_error(NotImplementedError)
  end

end
