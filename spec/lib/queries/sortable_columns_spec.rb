require 'rails_helper'

# Every sort key every filter exposes must produce valid SQL. Sort lists are
# largely auto-derived from schema and associations and built lazily on the
# first sorting request, so a bad entry (e.g. a column type Postgres can't
# order) would otherwise only surface as a 500 in production. EXPLAIN checks
# the SQL without needing any data.
Rails.autoloaders.main.eager_load_dir(Rails.root.join('lib/queries'))

describe 'Queries::Query::Filter sortable_columns', type: :model do
  sortable_filters = Queries::Query::Filter.descendants
    .reject { |k| k.sortable_columns.empty? }
    .sort_by(&:name)

  specify 'filters with sortable columns were found' do
    expect(sortable_filters.size).to be > 25
  end

  sortable_filters.each do |filter_class|
    specify "#{filter_class.name}: every sort key produces valid SQL" do
      failures = filter_class.sortable_columns_index.filter_map do |key|
        sql = filter_class.new(sort: key).all.to_sql
        ActiveRecord::Base.connection.transaction(requires_new: true) do
          ActiveRecord::Base.connection.execute("EXPLAIN #{sql}")
        end
        nil
      rescue ActiveRecord::StatementInvalid => e
        "#{key}: #{e.message.lines.first.strip}"
      end

      expect(failures).to be_empty, failures.join("\n")
    end
  end
end
