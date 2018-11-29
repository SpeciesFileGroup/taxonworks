class NomenclaturalRank::Icnp < NomenclaturalRank

  def self.group_base(rank_string)
    rank_string.match( /(NomenclaturalRank::Icnp::.+Group::).+/)
    $1
  end

end