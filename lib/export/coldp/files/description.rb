# taxonID
# category
# description
# language
# referenceID

module Export::Coldp::Files::Description

  # "supporting the taxonomic concept" 
  # Potentially- all other Citations tied to Otu, what exactly supports a concept?
  def self.reference_id(content)
    i = content.sources.pluck(:id)
    return i.join(',') if i.any?
    nil
    # TODO: add sources to reference list
  end

  def self.generate(otus)
    # TODO tabs delimit
    CSV.generate do |csv|
      otus.each do |o|
        o.contents.each do |c|
          csv << [
            o.id,
            c.topic_id, # TODO: refence EOL or related unitified topic DOIs
            c.text,
            c.language&.alpha_3_bibliographic,
           reference_id(c)
          ]
        end
      end
    end
  end
end

