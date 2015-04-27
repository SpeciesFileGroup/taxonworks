

Code Organization
=================

Our general approach to AR based models uses the pattern below.  Please use it.  Identifying sections
with comments _is not required_ and should only be done if absolutely necessary for use in active
development.

  ```
  class Foo << ActiveRecord::Base

    # Include statements, and acts_as_type
    include Housekeeping
    acts_as_nested_set

    # Aliases

    # Class constants
    BLORF = 123

    # Class variables
    @@foo = 1

    # Instance variables
    attr_accessor :foo

    # Callbacks
    after_save :attack!

    # Associations, in order: belongs_to, has_one,has_many
    belongs_to :source
    has_one :creator
    has_many :bars

    # Scopes, clustered by function
    scope :randum, -> {}

    # "Hard" Validations
    validates_presence_of :source

    # "Soft" Validations
    soft_validate(:sv_validate_parent_rank, set: :validate_parent_rank)


    # Getters/Setters
    def wings=(value)
      # ...
    end

    def wings
      # ...
    end
   
    # Class methods
    def self.swim!
      # ...
    end

    # Instance methods
    def walk!
      # ...
    end
 
    protected

    # Class methods
    def self.dive!
      # ...
    end

    # Instance methods
    def crawl
      # ...
    end

    # Callbacks
    def attack!
      #...
    end
  end 
  ```
