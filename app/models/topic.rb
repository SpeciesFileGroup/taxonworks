class Topic < ControlledVocabularyTerm

  include Shared::Taggable

  has_many :citation_topics, inverse_of: :topic, dependent: :destroy
  has_many :contents, inverse_of: :topic, dependent: :destroy
  has_many :contents
  has_many :otus, through: :contents
  has_many :otu_page_layout_sections, -> { where(otu_page_layout_sections: {type: 'OtuPageLayoutSection::StandardSection'}) }, inverse_of: :topic
  has_many :otu_page_layouts, through: :otu_page_layout_sections

  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    where_string = "name LIKE '#{term}' OR name ILIKE '%#{term}' OR name = '#{term}' OR definition ILIKE '%#{term}'"
    ControlledVocabularyTerm.where(where_string).where(project_id: params[:project_id], type: 'Topic')
  end

end
