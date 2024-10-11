# Stores the chronological relationship between two serials.
#
# @!attribute preceding_serial_id
#   @return [Integer]
#     the reference/historical serial
#
# @!attribute succeeding_serial_id
#   @return [Integer]
#     the "new" serial
#
# @!attribute type
#   @return [String]
#     the type of transition b/w the old and new
#
class SerialChronology < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData
  include Shared::SharedAcrossProjects

  belongs_to :preceding_serial, class_name: 'Serial', foreign_key: :preceding_serial_id, inverse_of: :preceding_serial_chronologies
  belongs_to :succeeding_serial, class_name: 'Serial', foreign_key: :succeeding_serial_id, inverse_of: :succeeding_serial_chronologies

  validates_presence_of :preceding_serial_id, :succeeding_serial_id, :type
end
