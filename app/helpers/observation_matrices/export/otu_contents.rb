module ObservationMatrices::Export::OtuContents

  def get_otu_contents(options = {})
    opt = {otus: []}.merge!(options)
    m = opt[:observation_matrix]

    a = {}
    otu_ids = m.otus.collect{|i| i.id}
    contents = Content.select('contents.*, controlled_vocabulary_terms.name, observation_matrix_rows.id AS row_id').joins(:topic).joins('INNER JOIN observation_matrix_rows ON observation_matrix_rows.otu_id = contents.otu_id').where('contents.otu_id IN (?)', otu_ids).where('observation_matrix_rows.observation_matrix_id = (?)', m.id).order(:otu_id, :topic_id)
    CSV.generate do |csv|
      csv << ['otu_id', 'topic', 'text']
      contents.each do |i|
        csv << ['row_' + i.row_id.to_s, i.name, i.text]
      end
    end
  end

end