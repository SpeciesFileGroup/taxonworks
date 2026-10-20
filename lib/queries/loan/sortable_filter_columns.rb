# `sortable_columns` for Queries::Loan::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Loan::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # created_by / updated_by display as user name; sort by users.name.
      cols['created_by'] = assoc(:creator, :name)
      cols['updated_by'] = assoc(:updater, :name)

      # identifiers aggregate: sort by alphabetically first identifier cached.
      cols['identifiers'] = assoc(:identifiers, :cached, collapse: :aggregate)

      # recipient_name / supervisor_name aggregate people through the loan
      # role tables (has_many :through); sort by the alphabetically first
      # person's cached name.
      cols['recipient_name'] = assoc(:loan_recipients, :cached, collapse: :aggregate)
      cols['supervisor_name'] = assoc(:loan_supervisors, :cached, collapse: :aggregate)

      cols
    end
  end
end
