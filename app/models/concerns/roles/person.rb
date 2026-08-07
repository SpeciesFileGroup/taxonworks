module Roles::Person
  extend ActiveSupport::Concern

  included do

    with_options if: :person_role? do
      after_save :vet_person
      after_save :update_person_year_metadata

      validates_uniqueness_of :person_id, scope: [:role_object_id, :role_object_type, :type], allow_nil: true
      validates :person, presence: true
    end

    after_destroy :check_for_last

    accepts_nested_attributes_for :person, reject_if: :all_blank, allow_destroy: true
  end

  protected

  def person_role?
    person.present? && organization.blank?
  end

  def check_for_last
    if is_last_role? && role_object_type == 'Source'
      add_touch = false
      if type == 'SourceAuthor'
        role_object.update_columns(author: nil, cached_author_string: nil)
        add_touch = true
      end
      if type == 'SourceEditor'
        add_touch = true
        role_object.update_columns(editor: nil)
      end
      role_object.touch
    else
      role_object.send(:set_cached) if role_object.respond_to?(:set_cached, true)
    end
  end

  # See /app/models/person.rb for a definition of vetted
  def vet_person
    # Check whether there are one or more *other* roles besides this one,
    # i.e. there are at least *2* for person_id
    if Role.where(person_id:).where.not(id:).any?
      person.update_column(:type, 'Person::Vetted')
    end
  end

  # @return [Year, nil]
  #   used to compare and update Person active_start/end values
  # The largest year attribte in the RoleObject
  #
  # Set in Role subclasses
  #
  def year_active_year
    nil
  end

  # Could be spun out to sublclasses but
  def update_person_year_metadata
    if y = year_active_year
      yas = [y, person.year_active_start].compact.map(&:to_i).min
      yae = [y, person.year_active_end].compact.map(&:to_i).max

      person.year_active_start = yas
      person.year_active_end = yae

      if person.valid?
        person.update_columns(year_active_start: yas, year_active_end: yae)
      else
        person.year_active_start = person.year_active_start_before_last_save
        person.year_active_end = person.year_active_end_before_last_save
      end
    end
    true
  end

end

