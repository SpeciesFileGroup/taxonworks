require 'rails_helper'

# Capabilities that consumers of Rails.cache (e.g. task_token) rely on.
describe 'Rails.cache' do
  include ActiveSupport::Testing::TimeHelpers

  specify 'is a :memory_store by default in test' do
    expect(Rails.cache).to be_a(ActiveSupport::Cache::MemoryStore)
  end

  context 'Solid Cache', :solid_cache do
    let(:key) { 'solid_cache_spec/key' }

    specify 'is Solid Cache' do
      expect(Rails.cache).to be_a(SolidCache::Store)
    end

    specify 'uses the solid database, not primary' do
      expect(SolidCache::Record.connection_db_config.name).to eq('solid')
      expect(SolidCache::Record.connection_db_config.database).not_to eq(ApplicationRecord.connection_db_config.database)
    end

    specify '#write/#read' do
      Rails.cache.write(key, 'value')
      expect(Rails.cache.read(key)).to eq('value')
    end

    specify 'honours expires_in' do
      Rails.cache.write(key, 'value', expires_in: 1.minute)
      travel 2.minutes do
        expect(Rails.cache.read(key)).to be_nil
      end
    end

    specify '#delete' do
      Rails.cache.write(key, 'value')
      Rails.cache.delete(key)
      expect(Rails.cache.read(key)).to be_nil
    end

    specify '#increment returns the new value' do
      Rails.cache.write(key, 0, raw: true)
      expect(Rails.cache.increment(key)).to eq(1)
      expect(Rails.cache.increment(key)).to eq(2)
    end

    specify '#increment keeps the existing expiry' do
      Rails.cache.write(key, 0, raw: true, expires_in: 1.minute)
      Rails.cache.increment(key)
      travel 2.minutes do
        expect(Rails.cache.read(key, raw: true)).to be_nil
      end
    end

    # Atomic only once the key exists: Solid Cache locks the existing row.
    # Concurrent increments of a MISSING key can both return 1, so consumers
    # must write the counter (e.g. 0) before relying on increment.
    context 'concurrent #increment of an existing key' do
      let(:results) do
        Rails.cache.write(key, 0, raw: true)

        5.times.map do
          Thread.new do
            SolidCache::Record.connection_pool.with_connection { Rails.cache.increment(key) }
          end
        end.map(&:value)
      end

      # nil is a failed increment (Solid Cache swallows database errors); consumers fail closed on nil
      specify 'never returns the same value twice' do
        values = results.compact
        expect(values).to eq(values.uniq)
      end

      specify 'every increment succeeds (PostgreSQL)' do
        skip 'SQLite rejects concurrent writers (busy), failed increments return nil' if SolidCache::Record.each_shard.map { SolidCache::Record.connection.adapter_name }.include?('SQLite')
        expect(results.sort).to eq([1, 2, 3, 4, 5])
      end
    end
  end
end
