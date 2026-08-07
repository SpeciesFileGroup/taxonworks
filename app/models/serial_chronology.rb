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
  validates_uniqueness_of :preceding_serial_id, scope: [:succeeding_serial_id]

  # Scaffolded from GPT 4o 21-5-2025 
  validate :no_self_reference
  validate :no_cycles

  private

  def no_self_reference
    if preceding_serial_id == succeeding_serial_id
      errors.add(:base, "A serial cannot precede or succeed itself")
    end
  end

  def no_cycles
    if creates_cycle?
      errors.add(:base, "This link would create a cycle in the chronology")
    end
  end

  def creates_cycle?
    # We want to see if the `preceding_serial` is reachable from the `succeeding_serial`
    # If so, adding this link would introduce a cycle
    visited = Set.new
    depth_first_search(succeeding_serial, visited).include?(preceding_serial)
  end

  def depth_first_search(serial, visited)
    return visited if visited.include?(serial)

    visited.add(serial)
    successors = SerialChronology.where(preceding_serial: serial).includes(:succeeding_serial).map(&:succeeding_serial)
    successors.each { |succ| depth_first_search(succ, visited) }

    visited
  end
end
