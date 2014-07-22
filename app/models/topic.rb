class Topic < ControlledVocabularyTerm
  has_many :citation_topics, inverse_of: :topic, dependent: :destroy
  has_many :contents, inverse_of: :topic, dependent: :destroy
  has_many :otus, through: :contents
  has_many :page_layout_sections, -> { where page_layout_section: {type: 'PageLayoutSection::StandardSection' } }, inverse_of: :topic
  has_many :page_layouts, through: :page_layout_sections
end
