# The result of a  parsing a row.
class BatchLoad::RowParse

  # Whether the row was parsed not
  attr_accessor :parsed

  attr_accessor :parse_errors

  # A bucket of all the objects created, indexed by class
  attr_accessor :objects


  def initialize
    @created = false
    @parsed = false
    @parse_errors = []
    @objects = {}
  end

  def has_parse_errors?
    parse_errors.size > 0
  end

  def has_object_errors?
    objects.select{|o| !o.valid?} > 0
  end

  def persisted_objects
    objects.collect{|type, objs| objs.select{|o| o.persisted?}}.flatten
  end

  def has_persisted_objects?
    persisted_objects.size > 0
  end

  def has_errored_objects?
    errored_objects.size > 0
  end

  def errored_objects
    objects.collect{|type, objs| objs.select{|o| !o.valid?}}.flatten
  end

  def all_objects
    objects.collect{|type, objs| objs}.flatten
  end

  def total_objects
    all_objects.size
  end

  def has_valid_objects?
    valid_objects.size > 0
  end

  def valid_objects
    objects.collect{|type, objs| objs.select{|o| o.valid?}}.flatten
  end

end
