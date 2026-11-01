require 'rails_helper'

# Every filter that permits its own `<model>_id` must restrict by it. If it
# doesn't, a request for specific records returns every record, which is the
# worst case for anything that acts on a filter's results (e.g. batch updates).
describe 'Queries::Query::Filter <model>_id', type: :model do
  marker = 987654321

  filters = ::Queries::Query::Filter.descendants
    .select { |k| k.name && k.const_defined?(:PARAMS, false) }
    .select { |k| k::PARAMS.flat_map { |p| p.is_a?(Hash) ? p.keys : [p] }.include?(:"#{k.base_name}_id") }
    .sort_by(&:name)

  before do
    # referenced_klass_intersection aliases with a random suffix
    allow(Utilities::Strings).to receive(:random_string) { |n| 'r' * n }
  end

  filters.each do |k|
    specify k.name do
      sql = ->(h) { k.new(ActionController::Parameters.new(h)).all.to_sql }
      base = sql.({})
      param = "#{k.base_name}_id"

      expect(sql.(param => marker)).not_to eq(base), "#{param}: #{marker} has no effect"
      expect(sql.(param => [marker])).not_to eq(base), "#{param}: [#{marker}] has no effect"
    end
  end
end
