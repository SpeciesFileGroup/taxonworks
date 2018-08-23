class NomenclaturalRank::Icn < NomenclaturalRank

  def self.group_base(rank_string)
    rank_string.match( /(NomenclaturalRank::Icn::.+Group::).+/)
    $1
  end

end

