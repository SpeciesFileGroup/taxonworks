class MatrixColumn < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable

  belongs_to :matrix
  belongs_to :descriptor

  acts_as_list

  validates_presence_of :matrix_id, :descriptor_id
  validates_uniqueness_of :descriptor_id, scope: [:matrix_id, :project_id]

end
