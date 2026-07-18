# `sortable_columns` for Queries::Loan::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Loan::SortableFilterColumns
  extend ActiveSupport::Concern

  SORTABLE_DIRECT_COLUMNS = %w[
    id lender_address date_requested request_method date_sent date_received
    date_return_expected is_gift recipient_address recipient_email
    recipient_phone recipient_country supervisor_email supervisor_phone
    date_closed recipient_honorific updated_at created_at
  ].freeze

  class_methods do
    def sortable_columns
      cols = {}

      SORTABLE_DIRECT_COLUMNS.each do |c|
        cols[c] = sort_by_direct_column("loans.#{c}")
      end

      # created_by / updated_by display as user name; sort by users.name.
      # Not `assoc()`-able: created_by_id/updated_by_id are plain housekeeping
      # columns with no declared `belongs_to :created_by`/`:updated_by`
      # association to reflect on (and User is blacklisted for sort-reachability
      # regardless).
      cols['created_by'] = sort_by_belongs_to_column(
        joined_table: 'users', joined_column: 'name',
        fk_expr: 'loans.created_by_id',
        alias_prefix: 'sort_created_by'
      )
      cols['updated_by'] = sort_by_belongs_to_column(
        joined_table: 'users', joined_column: 'name',
        fk_expr: 'loans.updated_by_id',
        alias_prefix: 'sort_updated_by'
      )

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
