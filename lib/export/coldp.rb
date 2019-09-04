module Export
  module Coldp
    
    # @return [Scope]
    #   should return the full set of Otus (= Taxa in CoLDP) that are to
    #   be sent.
    # TODO: include options for validity, sets of tags, etc. 
    def self.otus(otu_id)
      o = ::Otu.find(otu_id)
      return ::Otu.none if o.taxon_name_id.nil?
      a = o.taxon_name.descendants
      ::Otu.joins(:taxon_name).where(taxon_name: a) 
    end
  end
end
