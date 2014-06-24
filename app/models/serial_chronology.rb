class SerialChronology < ActiveRecord::Base
  belongs_to :preceding_serial, class_name: "Serial", foreign_key: :preceding_serial_id
  belongs_to :succeeding_serial, class_name: "Serial", foreign_key: :succeeding_serial_id

  validates :preceding_serial, presence: true
  validates :succeeding_serial, presence: true
end
