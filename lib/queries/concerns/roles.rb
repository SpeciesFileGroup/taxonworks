# Helpers for queries that reference Roles 
module Queries::Concerns::Roles

  extend ActiveSupport::Concern

  included do
  end

  # def set_roles_params(params)
  #   @people_ids = params[:people_ids].blank? ? [] : params[:people_ids]
  # end

  # @return [Arel::Table]
  def role_table 
    ::Role.arel_table
  end

  # @return [Arel::Table]
  def person_table 
    ::Person.arel_table
  end

  def matching_person_cached(role = nil)
    return nil if no_terms? || !role
    k = table.name.classify.safe_constantize

    k.where(
      ::Role.joins(:person)
      .where(
        role_table[:role_object_id].eq(table[:id])
      .and(role_table[:role_object_type].eq(table.name.classify))
      .and(person_table[:cached].matches(start_and_end_wildcard))
      .and(role_table[:type].eq(role.capitalize))
    ).arel.exists
    )
  end

end
