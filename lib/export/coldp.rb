module TaxonWorks::Export::Coldp

  # 
  # TODO
  #  - determine set of OTUs to export (base scope)
  #  - create project preferenct


  # a scope 
  def self.otus(otu_id)
    o = Otu.find(otu_id)

    return Otu.none if o.taxon_name_id.nil?
    
    a = o.taxon_name.descendants

    Otu.join(:taxon_name).where(taxon_name: a) 


  end


end
