class NomenclaturalRankOrder < ApplicationRecord

  has_many :taxon_names, inverse_of: 'nomenclatural_rank_order'

  def self.populate_db
    begin
      upsert_all(RANKS.each_with_index.map { |r, i| {rank_class: r, position: i} }, unique_by: :rank_class) if NomenclaturalRankOrder.table_exists?
    rescue ActiveRecord::NoDatabaseError
      # Happens during db:drop/db:create
    end
  end

end
