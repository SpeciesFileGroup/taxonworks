# The identifier whose origin and scope is unknown (i.e. can not be deduced after effort).
#
# Instantiating this class asserts that a namespace can not be determined.
#
# @!attribute identifier 
#   @return [String]
#   The *verbatim* value of this identifier.
class Identifier::Unknown < Identifier 
end
