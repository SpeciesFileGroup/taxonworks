require 'rails_helper'

RSpec.describe NomenclaturalRankOrder, type: :model do

  it 'Populates database on initialization with ordered copy or RANKS' do
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
