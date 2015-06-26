class PreparationType < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData
  include Shared::Taggable
  include Shared::SharedAcrossProjects
 
  has_paper_trail

  has_many :collection_objects, dependent: :restrict_with_error
  validates_presence_of :name, :definition

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

end
