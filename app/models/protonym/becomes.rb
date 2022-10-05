
# This module contains code that lets us convert Protonyms with very specific attributes into a Combination.  It is used almost exclusively during an import. 
module Protonym::Becomes
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  def becomes_test_for_relationship
    # a = TaxonNameRelationship::Iczn::Invalidating.where(subject_taxon_name: self).first ### This one returns all subclasses
    a = TaxonNameRelationship.where(subject_taxon_name: self, type: 'TaxonNameRelationship::Iczn::Invalidating').first
    if a.nil? || a.subject_taxon_name_id == a.object_taxon_name_id
      errors.add(:base, 'Required TaxonNameRelationship::Iczn::Invalidating relationship not found on this name.')
      false
    else
      a
    end
  end

  def becomes_test_for_original_genus
    if original_genus
      true
    else
      errors.add(:base, 'Protonym does not have original genus assigned.')
      false
    end
  end

  def becomes_test_for_similarity(invalidating_relationship)
    if invalidating_relationship.similar_homonym_string
      true
    else
      errors.add(:base, 'Related invalid name is not similar enough to protonym to be treated as combination.')
      false
    end
  end

  def becomes_test_classifications
    if taxon_name_classifications.any?
      errors.add(:base, 'Protonym has taxon name classifications, it can not be converted to combination.')
      false
    else
      true
    end
  end

  def becomes_test_for_other_relationships
    if related_taxon_name_relationships.with_type_base('TaxonNameRelationship::Iczn').any? || related_taxon_name_relationships.with_type_base('TaxonNameRelationship::Typification').any?
      errors.add(:base, 'Protonym has additional taxon name relationships, it can not be converted to combination.')
      false
    else
      true
    end
  end

  def becomes_test_for_original_relationships
    r = original_combination_relationships.load
    if r.select{|r| r.subject_taxon_name_id == id}.empty?
      errors.add(:base, 'Protonym is missing original combination relationship to self.')
      false
    else
      r 
    end
  end

  # @return [[taxon_name_relationship, original_relationships]]
  def convertable_to_combination?
    a = nil
    return false unless a = becomes_test_for_relationship
    return false unless becomes_test_for_similarity(a)
    return false unless becomes_test_for_original_genus 
    return false unless becomes_test_classifications
    return false unless becomes_test_for_other_relationships
    return false unless original_relationships = becomes_test_for_original_relationships
    return [a, original_relationships]
  end

  # Convert a Protonym into a Combination.
  # @return [self, or self as Combination]
  def becomes_combination
    a, original_relationships, c = nil, nil, nil

    if b = convertable_to_combination?
      a, original_relationships = b 
    else
      return self
    end

    begin
      Protonym.transaction do
        c = becomes!(Combination)

        c.assign_attributes(
          rank_class: nil,
          name: nil,
          verbatim_name: cached_original_combination,
          disable_combination_relationship_check: true
        )
        c.clear_cached

        # Destroy invalidating relationship, but note
        # what it references. 
        o = a.object_taxon_name
        a_id = a.id
        a.destroy!

        taxon_name_relationships.each do |r|
          next if r.object_taxon_name_id == r.subject_taxon_name_id
          next if r.id == a_id
          r.update_column(:subject_taxon_name_id, o.id)
        end

        original_relationships.each do |i|
          atr = { type: i.type.gsub(/TaxonNameRelationship::OriginalCombination::Original/, 'TaxonNameRelationship::Combination::' ) }
          if i.object_taxon_name_id == i.subject_taxon_name_id 
            atr[:subject_taxon_name_id] = o.id
          end

          i.update_columns(atr)
        end

        c.save!
        c.disable_combination_relationship_check = false
        c
      end

    # Note: technically a.destroy could hit this, but that should never happen.
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, 'Combination failed to save: ' + c.errors.full_messages.join('; '))
      c = becomes!(Protonym)
    rescue
      raise
    end

    c 
    # TODO: This fixes ./spec/models/combination/combination_spec.rb:62. But is returning `self` (or `z`) when fails trustworthy?
    # self
  end

end
