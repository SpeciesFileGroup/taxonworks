class Topic < ControlledVocabularyTerm
  has_many :citation_topics, inverse_of: :topic, dependent: :destroy
  has_many :contents, inverse_of: :topic, dependent: :destroy
  has_many :contents
  has_many :otus, through: :contents
  has_many :otu_page_layout_sections, -> { where(otu_page_layout_sections: {type: 'OtuPageLayoutSection::StandardSection'}) }, inverse_of: :topic
  has_many :otu_page_layouts, through: :otu_page_layout_sections

  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    ControlledVocabularyTerm.where('name LIKE ? OR definition ILIKE ? OR name ILIKE ? OR name = ?', term, "#{term}%", "%term", term ).where(project_id: params[:project_id], type: 'Topic')
  end

end
