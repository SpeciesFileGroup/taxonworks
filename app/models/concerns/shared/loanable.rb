# Shared code for data classes that can be loaned (used in LoanItem).
#
module Shared::Loanable

  extend ActiveSupport::Concern
  included do
    has_one :loan_item, as: :loan_item_object
    has_one :loan, through: :loan_item
  end

  module ClassMethods
  end

  def on_loan?
    !loan_item.blank?
  end

  def loan_return_date
    loan_item.try(:loan).try(:date_return_expected) ? loan_item.loan.date_return_expected : false
  end

end
