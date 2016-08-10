class MatrixRowItem < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable
  
  acts_as_list

  belongs_to :matrix
  belongs_to :collection_object
  belongs_to :otu
  belongs_to :controlled_vocabulary_term
  belongs_to :project

  validates_presence_of :matrix

  after_save :update_matrix_rows
  after_destroy :cleanup_matrix_rows

  def update_matrix_rows
    
  end

  def cleanup_matrix_rows
    rows = []
    rows << MatrixRow.where(otu_id: otus.map(&:id), matrix: matrix)
    rows << MatrixRow.where(collection_object_id: collection_objects.map(&:id), matrix: matrix)

    rows.each do |rc|
      current = rc.reference_count - 1

      if current == 0
        rc.delete
      else
        rc.update_columns(reference_count: current)
      end
    end
    true
  end

  # @return [Array]
  #   the otus "defined" by this matrix row item
  # override
  def otus
    false
  end

  # @return [Array]
  #   the collection objects "defined" by this matrix row item
  # override
  def collection_objects
    false
  end

  protected

  def
end

Dir[Rails.root.to_s + '/app/models/matrix_row_item/**/*.rb'].each { |file| require_dependency file }
