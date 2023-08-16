# taxonID
# category
# description
# language
# referenceID
#
module Export::Coldp::Files::Description

  # "supporting the taxonomic concept" 
  # Potentially- all other Citations tied to Otu, what exactly supports a concept?
  # Not used internally
  def self.reference_id(content)
    i = content.sources.pluck(:id)
    return i.join(',') if i.any?
    nil
  end

  def self.generate(otus, project_members, reference_csv = nil )
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{ 
        taxonID
        category
        description
        language
        referenceID
        modified
        modifiedBy
      }

      otus.joins(:contents).each do |o|
        o.contents.each do |c|

          sources = c.sources.load
          csv << [
            o.id,
            c.topic_id, # TODO: refence EOL or related unitified topic DOIs
            c.text,
            c.language&.alpha_3_bibliographic,
            sources.collect{|a| a.id}.join(','),
            Export::Coldp.modified(c[:updated_at]),                            # modified
            Export::Coldp.modified_by(c[:updated_by_id], project_members)      # modifiedBy
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv
        end
      end
    end
  end
end
