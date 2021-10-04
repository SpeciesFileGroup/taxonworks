class NomenclaturalRank::Icn < NomenclaturalRank

  KINGDOM = %w{Plantae Chromista Fungi}

  def self.group_base(rank_string)
    rank_string.match( /(NomenclaturalRank::Icn::.+Group::).+/)
    $1
  end

end

