# Stores the chronological relationship between two serials.
#
# @!attribute preceding_serial_id
#   @return [Integer]
#   @todo
#
# @!attribute succeeding_serial_id
#   @return [Integer]
#   @todo
#
# @!attribute type
#   @return [String]
#   @todo
#
class SerialChronology < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData
  include Shared::SharedAcrossProjects

  belongs_to :preceding_serial, class_name: "Serial", foreign_key: :preceding_serial_id
  belongs_to :succeeding_serial, class_name: "Serial", foreign_key: :succeeding_serial_id

  validates :preceding_serial, presence: true
  validates :succeeding_serial, presence: true
  validates_presence_of :type
end

