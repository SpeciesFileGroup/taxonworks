#
# http://api.col.plus/datapackage
# https://github.com/frictionlessdata/datapackage-rb
# https://github.com/frictionlessdata/tableschema-rb
#
#
# TODO: use https://github.com/frictionlessdata/datapackage-rb to ingest frictionless data,
# then each module will provide a correspond method to each field
# write tests to check for coverage (missing methods)
# 
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

  # columns = []
  # some_resource.fields.each do |f|
  #   columns.push get_value(f)
  # end
  #
  # capture no method
  #def get_value(f)
  #  if a = send(f)
  #    a
  #  else
  #    nil
  #  end
  #end

end
