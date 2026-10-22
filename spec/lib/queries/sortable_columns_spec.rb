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

  # Kaminari's pagination COUNT drops ORDER BY/LIMIT/OFFSET but keeps joins.
  # Postgres removes an unused LEFT JOIN from the plan only when it can prove
  # the join returns at most one row: a join on the target's primary key, or
  # a LATERAL that is a single aggregate (MIN, array_agg). A LATERAL with
  # LIMIT 1 is never removed, so sorting would make every page's COUNT pay
  # for the sort join. Join removal happens at plan time, so EXPLAIN on an
  # empty database shows it.
  #
  # dwc_occurrence is a has_one plain join; without a unique index on
  # (dwc_occurrence_object_type, dwc_occurrence_object_id) Postgres can't
  # prove it's at most one row, so those keys are exempt.
  COUNT_JOIN_EXEMPT = /\Adwc_occurrence\./

  plan_join_count = ->(sql) {
    ActiveRecord::Base.connection.select_all("EXPLAIN #{sql}").rows.flatten
      .join(' ').scan(/Join|Nested Loop|SubPlan/).size
  }

  sortable_filters.each do |filter_class|
    specify "#{filter_class.name}: sorting adds no joins to the pagination count" do
      count_sql = ->(params) {
        filter_class.new(params).all.except(:offset, :limit, :order).select('COUNT(*)').to_sql
      }
      unsorted = plan_join_count.(count_sql.({}))

      failures = filter_class.sortable_columns_index.filter_map do |key|
        next if key.match?(COUNT_JOIN_EXEMPT)
        key if plan_join_count.(count_sql.(sort: key)) > unsorted
      end

      expect(failures).to be_empty, "sort joins kept in COUNT: #{failures.join(', ')}"
    end
  end
end
