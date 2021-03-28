require_relative '../../lib/soft_validation'
# require 'rails_helper'

# Stub class for testing. Mimics only
# the ActiveRecord Model methods we need to test, 
# but see also FakeTable for future refactoring.
class Softy
  include SoftValidation

  # stub AR ancestors method
  def self.ancestors
    []
  end

  def self.column_names
    ['mohr']
  end 

  attr_accessor :hungry
  # This is called in test
  # soft_validate :has_cheezburgers?

  def initialize
    @hungry = true
  end

  def haz_cheezburgers?
    soft_validations.add(:base, 'hungry!', success_message: 'no longer hungry, cooked a cheezeburger', failure_message: 'missed my mouth') if @hungry
  end

  def needs_moar_cheez? 
    soft_validations.add(:mohr, 'hungry (for cheez)!') if @hungry 
  end

  def just_bun?
    soft_validations.add(:mohr, 'just bun!', ) if true 
  end

  def you_do_it?
    soft_validations.add(:mohr, 'fix it urselv!', resolution_with: __method__) if true 
  end

  def cook_cheezburgers
    @hungry = false
    true
  end
end

# Stub class for testing, used to ensure that soft validation
# methods are specific to a class
class OtherSofty < Softy
  # soft_validate(:bar)
  def self.column_names
    ['lezz']
  end

  # Mock ancestors method
  def self.ancestors
    [Softy]
  end
end

# Stub class for testing, used to ensure that soft validation
# methods are specific to a class
class OtherOtherSofty < Softy
  # soft_validate(:bar)
  def self.column_names
    ['lezz']
  end

  # Mock ancestors method
  def self.ancestors
    [Softy]
  end
end
