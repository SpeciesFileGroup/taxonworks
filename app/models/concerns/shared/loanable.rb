# Shared code for data classes that can be loaned (used in LoanItem).
#
module Shared::Loanable

  extend ActiveSupport::Concern
  included do
    has_one :loan_item, -> {where('date_returned is null')}, as: :loan_item_object
    has_one :loan, through: 'loan_item'

    has_many :loan_items, as: :loan_item_object 
    has_many :loans, through: :loan_items
  end

  module ClassMethods
  end

  def on_loan?
    !loan_item.blank? && !loan_item.returned?
  end

  def loan_return_date
    loan_item.try(:loan).try(:date_return_expected) ? loan_item.loan.date_return_expected : false
  end

  def times_loaned 
    loans.count 
  end

  def has_been_loaned?
    times_loaned > 0
  end

end
