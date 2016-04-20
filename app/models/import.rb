# A class used for transient data, primarily in the development of import scripts.  
#
# @!attribute metadata 
#   @return [Hstore]
#     an Hstore column
#
# @!attribute metadata_json 
#   @return [Json]
#     an JSON column
#
# Possible usage 
#   
#   i = Import.find_or_create_by_name('My Import')
#
#   # set some values
#
#   my_values = ['a', 'b', 'c']
# 
#   i.set('my_values_name', my_values)
#
#   i.get('my_values_name') # =>  ['a', 'b', 'c']
#
#
class Import < ActiveRecord::Base
  store_accessor :metadata

  validates_presence_of :name
  validates_uniqueness_of :name

  def set(key, value)
    h = metadata_json
    h ||= {} 
    h[key] = value
    update_attribute(:metadata_json, h) 
  end

  def get(key)
    metadata_json[key]
  end

end
