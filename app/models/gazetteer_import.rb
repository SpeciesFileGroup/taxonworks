# A GazetteerImport tracks the progress of a gazetteer import job.
#
# @!attribute num_records
#   @return [Integer]
#   The total number of records to be imported by this job
#
# @!attribute num_records_processed
#   @return [Integer]
#   The total number of records imported by this job - in practice this is
#   currently either 0 or num_records
#
# @!attribute aborted_reason
#   @return [String]
#   If the job is aborted, the reason it was aborted
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
#   into other projects as well)
#
class GazetteerImport < ApplicationRecord
  include Housekeeping
end
