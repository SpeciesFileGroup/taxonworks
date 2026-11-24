require 'rails_helper'

describe Support::Database do

  specify '.primary_config is the primary database configuration' do
    expect(Support::Database.primary_config[:database]).to eq(ApplicationRecord.connection.current_database)
  end

  context '.assert_solid_separate!' do
    let(:primary) { {adapter: 'postgis', host: 'db.example.org', port: 5432, database: 'taxonworks'} }

    specify 'raises when solid is the primary database' do
      solid = primary.merge(adapter: 'postgresql')
      expect { Support::Database.assert_solid_separate!(primary, solid) }.to raise_error(TaxonWorks::Error, /solid/)
    end

    specify 'raises when host and port are defaulted on one side only' do
      expect {
        Support::Database.assert_solid_separate!(
          {adapter: 'postgis', database: 'taxonworks'},
          {adapter: 'postgresql', host: 'localhost', port: '5432', database: 'taxonworks'}
        )
      }.to raise_error(TaxonWorks::Error)
    end

    specify 'passes for a different database on the same server' do
      solid = primary.merge(database: 'taxonworks_solid')
      expect(Support::Database.assert_solid_separate!(primary, solid)).to be(true)
    end

    specify 'passes for the same database name on a different host' do
      solid = primary.merge(host: 'cache.example.org')
      expect(Support::Database.assert_solid_separate!(primary, solid)).to be(true)
    end

    specify 'passes for the same database name on a different port' do
      solid = primary.merge(port: 5433)
      expect(Support::Database.assert_solid_separate!(primary, solid)).to be(true)
    end

    specify 'passes for a SQLite solid database' do
      solid = {adapter: 'sqlite3', database: 'taxonworks'}
      expect(Support::Database.assert_solid_separate!(primary, solid)).to be(true)
    end

    specify 'raises when solid is missing' do
      expect { Support::Database.assert_solid_separate!(primary, nil) }.to raise_error(TaxonWorks::Error, /solid/)
    end
  end

end
