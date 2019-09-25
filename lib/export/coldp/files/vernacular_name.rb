
# taxon_id
# name - ORIGINAL LANGUAGE
# transliteration - 
# language
# country
# area
# lifestage
# sex
# reference_id

module Export::Coldp::Files::VernacularName

  # return the 'English' translation(s) if available
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

  # TODO: Map to biocuration attribute?
  def self.life_stage(common_name)
    nil
  end

  # TODO: Map to biocuration attribute?
  def self.sex(common_name)
    nil
  end

  # "supporting the taxonomic concept" 
  # Potentially- all other Citations tied to Otu, what exactly supports a concept?
  def self.reference_id(common_name)
    i = common_name.sources.pluck(:id)
    return i.join(',') if i.any?
    nil
    # TODO: add sources to reference list
  end

  def self.generate(otus)
    # TODO tabs delimit
    CSV.generate do |csv|
      otus.each do |o|
        o.common_names.each do |n|
          csv << [
            o.id,
            n.name,
            transliteration(n),
            n.language&.alpha_3_bibliographic,
            n.geographic_area&.level0&.iso_3166_a2,
            area(n),
           reference_id(n)
          ]
        end
      end
    end
  end
end

