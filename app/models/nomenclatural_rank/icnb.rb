class NomenclaturalRank::Icnb < NomenclaturalRank

  def self.group_base(rank_string)
    rank_string.match( /(NomenclaturalRank::Icnb::.+Group::).+/)
    $1
  end

end