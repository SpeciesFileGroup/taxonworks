
# ID	parentID	nameID	provisional	accordingTo	accordingToID	accordingToDate	referenceID	fossil	recent	lifezone	link	remarks
module Export::Coldp::Files::Taxon

  def self.generate(otus)
    # TODO tabs delimit
    CSV.generate do |csv|
      otus.each do |o|
        csv << [o.id, o.parent_otu.id]
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

