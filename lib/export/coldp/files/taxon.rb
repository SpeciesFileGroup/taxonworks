
# ID	parentID	nameID	provisional	accordingTo	accordingToID	accordingToDate	referenceID	fossil	recent	lifezone	link	remarks


#







module Export::Coldp::Files::Taxon

  # return [Boolean, nil]
  #  TODO - reason in TW this is provision
  def self.provisional(otu)
    # nomen dubium
    # incertae sedis
    # unresolved homonym, without replacement
    #
    #    
    #
    # * if two OTUs for same name are in OTU set then both have to be provisional
    # * missaplication (?)
    nil 
  end

  # AttributionEditor
  #    * crawl attribution for inference on higher/lower 
  #    * UI/methods to assign/spam/visualize throught
  #    * project preference (!! should project preferences has reference ids? !!)
  # according to is the curator responsible for this OTU, comma delimited list of curators
  def self.according_to(otu)
    nil
  end

  #  ORCID only !!
  #  TODO: soft validation on Project ready for CoLDP
  def self.according_to_id(otu)
    nil
  end

  # Potentially reference 
  #    Confidence level 
  #       confidence_validated_at (last time this confidence level was deemed OK)
  def self.according_to_date(otu)
    # a) Dynamic - !! most recent update_at stamp for *any* OTU tied data -> this is a big grind: if so add cached_touched_on_date to Otu
    # b) modify Confidence level to include date
    # c) review what SFs does in their model 
    nil
  end

  # "supporting the taxonomic concept" 
  # Potentially- all other Citations tied to Otu, what exactly supports a concept?
  def self.reference_id(otu)
    otu.sources.pluck(:id).join(',')
    # TODO: add sources to reference list
  end


  # Predicates in TaxonWorks
  #   - make them default on Otu form
  #   - read in constants from API

  # default Predicates
  #   vs. calculated from CO
  def self.temporal_range_start(otu)
  end

  # default Predicates
  #   vs. calculated from CO
  def self.temporal_range_end(otu)
  end

  # @return [Boolean, nil]
  # Probably use default Predicate 'coldp_extinct'
  def self.extinct(otu)
  end

  # Derive from a default Predicate 
  #   when predicate created create URI to 
  #      http://api.col.plus/vocab/lifezone
  def self.lifezone(otu)
    # http://api.col.plus/vocab/lifezone
  end


  def self.link(otu)
   # API or public interface
  end

  # TODO: flag public
  def self.remarks(otu)
    otu.notes.pluck(:text).join('|')
  end

  def self.generate(otus)
    # TODO tabs delimit
    CSV.generate do |csv|
      otus.each do |o|
        csv << [
          o.id,                              # ID
          o.parent_otu.id,                   # parentID
          o.taxon_name.id,                   # nameID
          provisional(o),                    # provisional
          according_to(o),                   # accordingTo
          according_to_id(o),                # accordingToID
          according_to_date(o),              # accordingToDate
          reference_id(o),                   # referenceID
          extinct(o),                        # extinct
          temporal_range_start(o),           # temporalRangeStart
          temporal_range_end(o),             # temporalRangeEnd
          lifezone(o),                       # lifezone
          link(o),                           # link
          remarks(o)                         # remarks
        ]
      end
    end
  end

  # if table_data.nil?
  #   scope.order(id: :asc).each do |c_o|
  #     row = [c_o.otu_id,
  #            c_o.otu_name,
  #            c_o.name_at_rank_string(:family),
  #            c_o.name_at_rank_string(:genus),
  #            c_o.name_at_rank_string(:species),
  #            c_o.collecting_event.country_name,
  #            c_o.collecting_event.state_name,
  #            c_o.collecting_event.county_name,
  #            c_o.collecting_event.verbatim_locality,
  #            c_o.collecting_event.georeference_latitude.to_s,
  #            c_o.collecting_event.georeference_longitude.to_s
  #     ]
  #     row += ce_attributes(c_o, col_defs)
  #     row += co_attributes(c_o, col_defs)
  #     row += bc_attributes(c_o, col_defs)
  #     csv << row.collect { |item|
  #       item.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
  #     }

  #   end
  # else
  #   table_data.each_value { |value|
  #     csv << value.collect { |item|
  #       item.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
  #     }
  #   }
  # end
end

