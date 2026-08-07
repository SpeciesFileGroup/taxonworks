# A GazetteerImport tracks the progress of a gazetteer import job.
#
# @!attribute num_records
#   @return [Integer]
#   The total number of records to be imported by this job
#
# @!attribute num_records_imported
#   @return [Integer]
#   The total number of records successfully imported by this job so far
#
# @!attribute project_names
#   @return [String]
#   A string list of the names of the projects into which these gazetteers are
#   being imported (for reporting purposes)
#
# @!attribute error_messages
#   @return [String]
#   A digest of all errors encountered during shapefile processing
#
# @!attribute started_at
#   @return [DateTime]
#   When processing began
#
# @!attribute ended_at
#   @return [DateTime]
#   When processing ended
#
# @!attribute project_id
#   @return [Integer]
#   The project from which the import job is run (the job may import gazetteers
#   into other projects as well - see project_names)
#
class GazetteerImport < ApplicationRecord
  include Housekeeping
end
