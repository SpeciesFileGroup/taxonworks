require 'rails_helper'

RSpec.describe NomenclaturalRankOrder, type: :model do

  xit 'Populates database on initialization with ordered copy or RANKS' do
    # TODO: If ActiveRecord::Migration.maintain_test_schema! feels sync is required it destroys the database AFTER initialization occurred.
    # Presently this test passes on a second run rspec/rake onwards when test schema is out of sync.
    # Current workaround is testing database is populated when testing built docker images in Travs CI
    db_copy = NomenclaturalRankOrder.order(:position).map { |r| r.rank_class }

    expect(db_copy).to eq(RANKS)
  end

  it 'NomenclaturalRankOrder.populate_db is idemponent' do
    before = NomenclaturalRankOrder.all
    NomenclaturalRankOrder.populate_db
    after = NomenclaturalRankOrder.all

    expect(before).to eq(after)
  end

end
