# Shared code for data classes that can be loaned (used in LoanItem).
#
module Shared::Loanable

  extend ActiveSupport::Concern
  included do

    #
    # !! These do not take into account potential Container loans
    #

    has_one :loan_item, -> {where('date_returned is null')}, as: :loan_item_object, inverse_of: :loan_item_object
    has_one :loan, through: 'loan_item'

    has_many :loan_items, as: :loan_item_object, dependent: :destroy, inverse_of: :loan_item_object
    has_many :loans, through: :loan_items # See also "all loans"
  end

  # Note that these do not "dig" into potentially containing containers
  # See instance methods for that check.
  module ClassMethods
    def loaned
      joins(:loan_items)
    end

    def on_loan
      joins(:loan_items).where(loan_items: { date_returned: nil })
    end

    def never_loaned
      where.missing(:loan_items)
    end
  end

  # @return True
  #   whether this object has this concern, NOT whether it is currently
  #   in possesion to be loaned out
  def is_loanable?
    true
  end

  # @return Container, false
  #   the container that was loaned
  #   !! Not necessarily the immediate current container
  def loaned_in_container
    if self.class.is_containable?
      if contained?
        return container if container.loan_item # !! Do not use .on_loan? !!
        container.enclosing_containers.each do |c|
          return c if c.loan_item # !! Do not use .on_loan? !!
        end
      end
    end
    false
  end

  # @return False, Container
  def container_loaned?
    # OTUs are not containable, but they can be "virtual" loan items.
    if c = loaned_in_container
      c
    else
      false
    end
  end

  # @return Boolean
  # Accounts for Containers
  def on_loan?
    return true if container_loaned?
    loan_item.present? && !loan_item.returned?
  end

  def current_loan
    current_loan_item&.loan
  end

  # @return Boolean
  def current_loan_item
    if a = loan_item
      return a
    elsif c = container_loaned?
      return c.loan_item
    end
    false
  end

  # @return date, False
  def loan_return_date
    if loan_item
      loan_item&.loan&.date_return_expected ? loan_item.loan.date_return_expected : false
    elsif c = loaned_in_container
      i = c.loan_item
      i.loan.date_return_expected? || false
    else
      false
    end
  end

  def times_loaned
    loans.count + container_times_loaned
  end

  # @return Integer
  def container_times_loaned
    # OTUs can't be contained, everything else loanable can
    return 0 if loan_item&.loan_item_object_type == 'Otu'
    if container
      total = container_loan_items.count
    else
      0
    end
  end

  def all_loans
    loans + container_loans
  end

  def all_loan_items
    loan_items + container_loan_items
  end

  def has_been_loaned?
    times_loaned > 0
  end

  def container_loan_items
    return [] if loan_item&.loan_item_object_type == 'Otu'
    return [] unless contained?
    container_ids = [container.id]
    container_ids += container.container_item.ancestors.pluck(:contained_object_id)
    LoanItem.where(loan_item_object_id: container_ids, loan_item_object_type: 'Container')
  end

  def container_loans
    Loan.joins(:loan_items).where(loan_items: container_loan_items).distinct
  end

end
