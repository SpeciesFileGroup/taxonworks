module Utilities::Transmute
  # Move shared associations from one ActiveRecord instance (`source`) to
  # another (`target`).
  #
  # This is designed for moving associations to a fresh, empty target record
  # (e.g., transmuting a CollectionObject into a FieldOccurrence).
  #
  # @param source [ActiveRecord::Base] the record from which to move associations
  # @param target [ActiveRecord::Base] the record to which associations are moved
  # @return [void] Raises exceptions on error
  #
  # This utility inspects ActiveRecord reflections to find associations that
  # both `source` and `target` define. For each shared association:
  #
  #   * has_one  – The associated record is reassigned to `target`.
  #   * has_many – Each associated record is reassigned to `target`.
  #
  # Associations that are skipped:
  #   * belongs_to – Explicitly excluded. These should already be set on target.
  #   * through – Skipped as these are convenience relations built on top of
  #               other associations.
  #
  # @example
  #   co = CollectionObject.find(123)
  #   fo = FieldOccurrence.new(collecting_event: co.collecting_event)
  #   fo.save!
  #   Utilities::Transmute.move_associations(co, fo)
  #
  def self.move_associations(source, target)
    source.class.reflections.each_value do |reflection|
      # Skip belongs_to - those should already be set on target
      next if reflection.macro == :belongs_to

      # Skip through associations - they're convenience relations
      next if reflection.options[:through]

      # Only process if target class has the same association
      next unless target.class.reflections.key?(reflection.name.to_s)

      case reflection.macro
      when :has_one
        move_has_one(source, target, reflection)
      when :has_many
        move_has_many(source, target, reflection)
      end
    end
  end

  private

  def self.move_has_one(source, target, reflection)
    associated = source.send(reflection.name)
    return unless associated

    # Skip dwc_occurrence - target will get its own
    return if reflection.name.to_s == 'dwc_occurrence'

    # Update the foreign key to point to target
    associated.update!(reflection.foreign_key => target.id)
  end

  def self.move_has_many(source, target, reflection)
    source.send(reflection.name).each do |associated|
      # Skip DWC Occurrence identifiers - target will get its own
      next if associated.is_a?(Identifier::Global::Uuid::TaxonworksDwcOccurrence)

      # For polymorphic associations, we need to update both the _id and _type fields
      if reflection.options[:as]
        # This is a polymorphic association
        foreign_type = reflection.type
        # Use update_columns to bypass callbacks
        # This preserves data like UUID values that would otherwise be regenerated
        associated.update_columns(
          reflection.foreign_key => target.id,
          foreign_type => target.class.base_class.name
        )
      else
        # Regular association - just reassign
        target.send(reflection.name) << associated
      end
    end
  end
end
