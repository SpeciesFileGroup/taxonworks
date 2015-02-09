
# The DataAttribute that has an externally referenced (and likely undefined) predicate.  
#
# ImportAttributes are used to attach data to other TW data in cases where the user is unclear
# as to the meaning of the related data.  For example, if a spreadsheet is batch imported it 
# might be that 4 of the 10 columns could be mapped to a concept, say CollectionObject, in TW.  The remaining
# 6 columns do not nicely map.  If the user wants to associate the data from those 6 columns she can
# include them as import attributes.  In this case the column header is the @import_predicate.  
#
# Use with caution, typically as a means to maintain legacy values on import.
#
# For example: 
#
#  attribute_subject  import_predicate       value
#  @some_otu          "times_seen_in_lake"   14
#
# or
#
#  attribute_subject  import_predicate       value
#  @some_specimen     'has_part'            'some_uri'
#
# or
#
#  attribute_subject       import_predicate  value
#  @some_collecting_event  "micro_habitat"   "north side of wet rock"
#
#
#
# @!attribute import_predicate 
#   @return [string]
#   The predicate literal.  For example a column header.  
#
#
class ImportAttribute < DataAttribute
   validates_presence_of :import_predicate
end
