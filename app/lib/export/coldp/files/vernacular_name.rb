# taxon_id
# name - ORIGINAL LANGUAGE
# transliteration
# language
# country
# area
# sex
# reference_id
# modified
# modifiedBy
#
module Export::Coldp::Files::VernacularName

  # @return [String, nil]
  #   the 'English' translation(s) if available
  def self.transliteration(common_name)
    n = common_name.alternate_values.where(type: 'AlternateValue::Translation', alternate_value_object_attribute: :name).load
    if n.any?
      n.collect{|a| a.language.name == 'English' ? a.language.name : nil}.compact.join('; ')
    else
      nil
    end
  end

  def self.area(common_name)
    common_name.geographic_area&.self_and_ancestors&.collect{|a| a.name}&.join('; ')
  end

  # TODO: Map to biocuration attribute via URI
  def self.sex(common_name)
    nil
  end

  # @return [String, nil]
  # "supporting the taxonomic concept"
  # Potentially- all other Citations tied to OTU, what exactly supports a concept?
  #   Not used internally within CoLDP, for reference only. TODO: confirm.
  def self.reference_id(common_name)
    i = common_name.sources.pluck(:id)
    return i.join(',') if i.any?
    nil
  end

  def self.generate(otus, project_members, reference_csv = nil )
    ::CSV.generate(col_sep: "\t") do |csv|

      # TODO: Biocuration attributes on these two
      # sex

      csv << %w{
        taxonID
        name
        transliteration
        language
        country
        area
        referenceID
        modified
        modifiedBy
      }

      otus.joins(:common_names).each do |o|
        o.common_names.each do |n|
          sources = n.sources.load

          csv << [
            o.id,                                                          # taxon_id
            n.name,                                                        # name
            transliteration(n),                                            # transliteration
            n.language&.alpha_3_bibliographic,                             # language
            n.geographic_area&.level0&.iso_3166_a2,                        # country
            area(n),                                                       # area
            sources.collect{|a| a.id}.join(','),                           # reference_id
            Export::Coldp.modified(n[:updated_at]),                        # modified
            Export::Coldp.modified_by(n[:updated_by_id], project_members)  # modified_by
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv && sources.any?
        end
      end
    end
  end
end
