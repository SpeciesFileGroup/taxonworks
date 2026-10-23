require 'rails_helper'

# Every sort key of every Queries::<Model>::Sort must produce valid SQL. Sort lists are
# largely auto-derived from schema and associations and built lazily on the
# first sorting request, so a bad entry (e.g. a column type Postgres can't
# order) would otherwise only surface as a 500 in production. EXPLAIN checks
# the SQL without needing any data.
Rails.autoloaders.main.eager_load_dir(Rails.root.join('lib/queries'))

describe 'Queries::Sort::Base columns', type: :model do
  sort_classes = Queries::Sort::Base.descendants
    .select { |k| k.name&.end_with?('::Sort') }
    .sort_by(&:name)

  sorted_set = ->(sort_class, key) {
    Queries::Pager.new(sort_class.referenced_klass.all, sort: key).ordered
  }

  specify 'sort classes were found' do
    expect(sort_classes.size).to be > 25
  end

  sort_classes.each do |sort_class|
    specify "#{sort_class.name}: every sort key produces valid SQL" do
      failures = sort_class.keys.filter_map do |key|
        sql = sorted_set.(sort_class, key).to_sql
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
  # A has_one sort (e.g. dwc_occurrence) is a plain join, so it needs a unique
  # index on the target's foreign key (+ type) for Postgres to drop it.

  plan_join_count = ->(sql) {
    ActiveRecord::Base.connection.select_all("EXPLAIN #{sql}").rows.flatten
      .join(' ').scan(/Join|Nested Loop|SubPlan/).size
  }

  sort_classes.each do |sort_class|
    specify "#{sort_class.name}: sorting adds no joins to the pagination count" do
      count_sql = ->(key) {
        sorted_set.(sort_class, key).except(:offset, :limit, :order).select('COUNT(*)').to_sql
      }
      unsorted = plan_join_count.(count_sql.(nil))

      failures = sort_class.keys.filter_map do |key|
        key if plan_join_count.(count_sql.(key)) > unsorted
      end

      expect(failures).to be_empty, "sort joins kept in COUNT: #{failures.join(', ')}"
    end
  end
end
