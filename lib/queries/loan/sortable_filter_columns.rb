# `sortable_columns` for Queries::Loan::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Loan::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # created_by / updated_by display as user name; sort by users.name.
      cols['created_by'] = association(:creator, :name)
      cols['updated_by'] = association(:updater, :name)

      # Sort by the identifiers as the table shows them: in position order, joined.
      cols['identifiers'] = association(:identifiers, :cached, collapse: :joined)

      # recipient_name / supervisor_name aggregate people through the loan
      # role tables (has_many :through); sort by the alphabetically first
      # person's cached name.
      cols['recipient_name'] = association(:loan_recipients, :cached, collapse: :aggregate)
      cols['supervisor_name'] = association(:loan_supervisors, :cached, collapse: :aggregate)

      cols
    end
  end
end
