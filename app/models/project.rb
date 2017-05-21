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
  validates_uniqueness_of :name

  def clear_workbench_settings
    self.update('workbench_settings' => DEFAULT_WORKBENCH_SETTINGS)
  end

  # !! This is not production ready.
  # @return [Boolean]
  #   based on whether the project has successfully been deleted.  Can also raise on detected problems with configuration.
  def nuke
    known = ActiveRecord::Base.subclasses.select { |a| a.column_names.include?('project_id') }.map(&:name)

    order = %w{
     DwcOccurrence
     ProtocolRelationship
     Protocol
     AlternateValue
     DataAttribute 
     CitationTopic
     Citation
     SqedDepiction 
     Depiction
     Documentation
     Document 
     CollectionObjectObservation  
     DerivedCollectionObject        
     Note
     PinboardItem
     TaggedSectionKeyword      
     Tag
     Confidence 
     Role
     AssertedDistribution
     BiocurationClassification
     BiologicalRelationshipType   
     BiologicalAssociationsBiologicalAssociationsGraph
     BiologicalAssociation
     BiologicalRelationship
     BiologicalAssociationsGraph   
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
     TypeMaterial       
     CollectionObject   
     CollectingEvent
     RangedLotCategory
     Image  
     CommonName
     Otu 
     TaxonNameClassification
     TaxonNameRelationship
     TaxonName 
     ControlledVocabularyTerm
     OriginRelationship
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
    # Calling TaxonName is a hack to load the required has_many into Project, 
    # "has_many :taxon_names" is invoked through TaxonName within Housekeeping::Project 
    # Within TaxonName closure_tree (appears to?) require a database connection.  Note 
    # closure_tree is apparently not robustly tested for Ruby 2.3.
    # Since we shouldn't (can't?) initiate a connection prior to a require_dependency
    # we simply load TaxonName for the first time here.
    TaxonName.tap{}  
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


