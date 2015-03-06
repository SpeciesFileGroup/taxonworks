class Topic < ControlledVocabularyTerm
  has_many :citation_topics, inverse_of: :topic, dependent: :destroy
  has_many :contents, inverse_of: :topic, dependent: :destroy
  has_many :contents
  has_many :otus, through: :contents
  has_many :otu_page_layout_sections, -> { where(otu_page_layout_sections: {type: 'OtuPageLayoutSection::StandardSection'}) }, inverse_of: :topic
  has_many :otu_page_layouts, through: :otu_page_layout_sections

end
