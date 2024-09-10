# A GazetteerImport tracks the progress of a gazetteer import job.
#
# @!attribute num_records
#   @return [Integer]
#   The total number of records to be imported by this job
#
# @!attribute num_records_processed
#   @return [Integer]
#   The total number of records imported by this job so far
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
#   The project the gazetteers are being imported into
#
class GazetteerImport < ApplicationRecord
  include Housekeeping
end
