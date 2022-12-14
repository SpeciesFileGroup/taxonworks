# taxonID
# areaID
# area
# gazetteer
# status
# referenceID
# remarks
#
module Export::Coldp::Files::Distribution

  def self.reference_id(content)
    i = content.sources.pluck(:id)
    return i.join(',') if i.any?
    nil
  end

  def self.generate(otus, reference_csv = nil )
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        taxonID
        areaID
        area
        gazetteer
        status
        referenceID
        remarks
      }

      otus.each do |o|
        o.asserted_distributions.includes(:geographic_area).each do |ad|

          ga = ad.geographic_area
          if !ga.iso_3166_a3.blank?
            gazetteer = 'iso'
            area_id = ga.iso_3166_a3
            area = ga.iso_3166_a3
          elsif !ga.iso_3166_a2.blank?
            gazetteer = 'iso'
            area_id = ga.iso_3166_a2
            area = ga.iso_3166_a2
          elsif !ga.tdwgID.blank?
            gazetteer = 'tdwg'
            if ga.data_origin == 'tdwg_l3' or ga.data_origin == 'tdwg_l4'
              area_id = ga.tdwgID.gsub(/^[0-9]{1,2}(.+)$/, '\1')  # fixes mismatch in TW vs CoL TDWG level 3 & 4 identifiers
            else
              area_id = ga.tdwgID
            end
            area = area_id
          else
            gazetteer = 'text'
            area_id = nil
            area = ga.name
          end

          sources = ad.sources.load
          reference_ids = sources.collect{|a| a.id}
          csv << [
            o.id,
            area_id,
            area,
            gazetteer,
            nil,
            reference_ids.first,  # only 1 distribution reference allowed
            nil
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
        end
      end

      otus.joins("INNER JOIN contents ON contents.otu_id = otus.id
                  INNER JOIN controlled_vocabulary_terms ON controlled_vocabulary_terms.id = contents.topic_id")
          .select("otus.id, contents.text")
          .where("controlled_vocabulary_terms.name = 'Distribution text'").distinct.each do |o|
        area = o.text

        csv << [
          o.id,
          nil,
          area,
          'text',
          nil,
          nil,
          nil
        ]
      end
    end
  end
end
