# Code Organization

Our general approach to AR based models uses the pattern below.  Please use it.


  ```
  class Foo << ApplicationRecord

    # Include statements
    include Housekeeping

    # acts_as, has_ etc. includes
    acts_as_nested_set

    # If there are cached values to set they
    # must be set *after* save.
    after_save :set_cached

    # Aliases

    # Class constants
    BLORF = 123

    # We do not use Class variables in ApplicationRecord subclasses
    # @@foo = 1  # NO

    # We do not use Globals (anywhere)
    $bar = 1 # NO

    # Instance variables
    attr_accessor :foo

    # Callbacks
    after_save :attack!

    # Associations, in order: belongs_to, has_one,has_many
    belongs_to :source
    has_one :creator
    has_many :bars

    # nested_attributes
    accepts_nested_attributes_for

    # Scopes, clustered by function
    scope :randum, -> {}

    # "Hard" Validations
    validates_presence_of :source

    # "Soft" Validations
    soft_validate(:sv_validate_parent_rank, set: :validate_parent_rank)

    # Getters/Setters for attr_ attributes
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

    # Soft validation methods
    def sv_safe
      #...
    end

    # A manifest of all cache setting values.  Must be the only
    # method called to set all.
    def set_cached
      cached_method1
      cached_method2
    end

    # Cached setting methods must be isolated from set_cached
    def cached_method1
      # cache setting methods must not trigger ActiveRecord callbacks!
      update_column()
    end

  end
```

# Naming methods and variables
* See `[/ARCHITECTURE.md](/ARCHITECTURE.md)`
* There is one exception to above, soft validation tests and fixes are prefixed with `sv_`

# Commenting code
* Do not leave commented out code for reminders etc. after test pass. We can use past commits to look up past work.
* Prefer inline commenting rather than begin/end
* Use uppercase `TODO` when referencing
* Do not use comments to define sections, rather organize code consistently as above

