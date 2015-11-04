# A project is a team's wrapper for a group of data.  Most data is project specific, with a few exceptions.  A project has many users, and one or more project administrators.
# With the exception of "Workers" who can only see and therefore use certain elements of the workbench all members of a project share the same privileges.  A projects
# members are therefor well trained and trusted contributors to the project.
#
# @!attribute name
#   @return [String]
#     The name of the project 
#
# @!attribute workbench_settings
#   @return [Hash]
#     Settings for the project (for all users)   
#
class Project < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Housekeeping::AssociationHelpers

  store_accessor :workbench_settings, :worker_tasks, :workbench_starting_path

  attr_accessor :without_root_taxon_name

  DEFAULT_WORKBENCH_STARTING_PATH = '/hub'
  DEFAULT_WORKBENCH_SETTINGS = {
      'workbench_starting_path' => DEFAULT_WORKBENCH_STARTING_PATH
  }

  has_many :project_members, dependent: :restrict_with_error
  has_many :users, through: :project_members
  has_many :sources, through: :project_sources
  has_many :project_sources, dependent: :restrict_with_error

  after_initialize :set_default_workbench_settings
  after_create :create_root_taxon_name, unless: 'self.without_root_taxon_name == true'

  validates_presence_of :name

  def clear_workbench_settings
    self.update('workbench_settings' => DEFAULT_WORKBENCH_SETTINGS)
  end

  # !! This is not production ready.
  # @return [Boolean]
  #   based on whether the project has successfully been deleted.  Can also raise on detected problems with configuration.
  def nuke
    known = ActiveRecord::Base.subclasses.select { |a| a.column_names.include?('project_id') }.map(&:name)

    order = %w{
     AlternateValue
     DataAttribute 
     SqedDepiction 
     Depiction
     CollectionObjectObservation  
     DerivedCollectionObject        
     Note
     PinboardItem
     Tag
     Role
     TaggedSectionKeyword   
     AssertedDistribution
     BiocurationClassification
     BiologicalRelationshipType   
     BiologicalAssociationsBiologicalAssociationsGraph
     BiologicalAssociation
     BiologicalRelationship
     BiologicalAssociationsGraph   
     CitationTopic
     Citation
     CollectionProfile   
     ContainerLabel
     ContainerItem  
     Container
     PublicContent
     Content
     Georeference
     Identifier
     LoanItem  
     Loan
     OtuPageLayoutSection   
     OtuPageLayout
     ProjectSource
     TaxonDetermination
     CollectingEvent
     TypeMaterial     
     CollectionObject
     RangedLotCategory
     Image  
     Otu 
     TaxonNameClassification
     TaxonNameRelationship
     TaxonName 
     ControlledVocabularyTerm
     ProjectMember  
    }

    known.each do |k|
      next if k.constantize.table_name == 'test_classes' # TODO: a kludge to ignore stubbed classes in testing
      if !order.include?(k)
        raise "#{k} has not been added to #nuke order."
      end
    end

    begin
      order.each do |o|
        klass = o.constantize
        klass.where(project_id: id).delete_all
      end

      self.destroy

      true
    rescue => e
      raise e
    end
  end


  def root_taxon_name
    self.taxon_names.root
  end

  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

  protected

  def set_default_workbench_settings
    self.workbench_settings = DEFAULT_WORKBENCH_SETTINGS.merge(self.workbench_settings ||= {})
  end

  def create_root_taxon_name
    Protonym.create!(name: 'Root', rank_class: NomenclaturalRank, parent_id: nil, project: self, creator: self.creator, updater: self.updater)
  end

end
