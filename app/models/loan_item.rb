# A loan item is a CollectionObject, Container, or historical reference to
# something that has been loaned via (Otu)
#
# Thanks to https://neanderslob.com/2015/11/03/polymorphic-associations-the-smart-way-using-global-ids/ for global_entity.
#
# @!attribute loan_id
#   @return [Integer]
#   Id of the loan
#
# @!attribute loan_item_object_type
#   @return [String]
#   Polymorphic- one of Container, CollectionObject, or Otu
#
# @!attribute loan_item_object_id
#   @return [Integer]
#   Polymorphic, the id of the Container, CollectionObject or Otu
#
# @!attribute date_returned
#   @return [DateTime]
#   The date the item was returned.
#
# @!attribute disposition
#   @return [String]
#     an evolving controlled vocabulary used to differentiate loan object status when it differs from that of the overal loan, see LoanItem::STATUS
#
# @!attribute position
#   @return [Integer]
#    Sorts the items in relation to the loan.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute total
#   @return [Integer]
#     when type is OTU an arbitrary total can be provided
#
class LoanItem < ApplicationRecord
  acts_as_list scope: [:loan, :project_id]

  include Housekeeping
  include Shared::DataAttributes
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData

  attr_accessor :date_returned_jquery

  STATUS = ['Destroyed', 'Donated', 'Loaned on', 'Lost', 'Retained', 'Returned'].freeze

  belongs_to :loan, inverse_of: :loan_items
  belongs_to :loan_item_object, polymorphic: true

  validates_presence_of :loan_item_object

  validates :loan, presence: true

  # validates_uniqueness_of :loan, scope: [:loan_item_object_type, :loan_item_object_id]

  validate :total_provided_only_when_otu

  validate :loan_object_is_loanable

  validate :available_for_loan

  validates_uniqueness_of :loan_id, scope: [:loan_item_object_id, :loan_item_object_type], if: -> { loan_item_object_type == 'CollectionObject' }

  validates_inclusion_of :disposition, in: STATUS, if: -> {disposition.present?}

  def global_entity
    self.loan_item_object.to_global_id if self.loan_item_object.present?
  end

  def global_entity=(entity)
    self.loan_item_object = GlobalID::Locator.locate entity
  end

  def date_returned_jquery=(date)
    self.date_returned = date.gsub(/(\d+)\/(\d+)\/(\d+)/, '\2/\1/\3')
  end

  def date_returned_jquery
    self.date_returned
  end

  def returned?
    date_returned.present?
  end

  # @return [Integer, nil]
  #   the total items this loan line item represent
  # TODO: this does not factor in nested items in a container
  def total_items
    case loan_item_object_type
      when 'Otu'
        total ? total : nil
      when 'Container'
        t = 0
        loan_item_object.all_contained_objects.each do |o|
          if o.kind_of?(::CollectionObject)
            t += o.total
          end
        end
        t
      when 'CollectionObject'
        loan_item_object.total.to_i
      else
        nil
    end
  end

  # @return [Array]
  #   all objects that can have a taxon determination applied to them for this loan item
  def determinable_objects
    # this loan item which may be a container, an OTU, or a collection object
    case loan_item_object_type
    when /contain/i # if this item is a container, dig into the container for the collection objects themselves
      loan_item_object.collection_objects
    when /object/i # if this item is a collection object, just add the object
      [loan_item_object]
    when /otu/i # not strictly needed, but helps keep track of what the loan_item is.
      [] # can't use an OTU as a determination object.
    end
  end

  # @params :ids -> an ID of a loan_item
  def self.batch_determine_loan_items(ids: [], params: {})
    return false if ids.empty?
    # these objects will be created/persisted to be used for each of the loan items identified by the input ids
    td = TaxonDetermination.new(params) # build a td from the input data

    begin
      LoanItem.transaction do
        item_list = [] # Array of objects that can have a taxon determination
        LoanItem.where(id: ids).each do |li|
          item_list.push li.determinable_objects
        end

        item_list.flatten!

        first = item_list.pop
        td.taxon_determination_object = first
        td.save! # create and save the first one so we can dup it in the next step

        item_list.each do |item|
          n = td.dup
          n.determiners << td.determiners
          n.taxon_determination_object = item
          n.save
          n.move_to_top
        end
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
    true
  end

  # TODO: param handling is currently all kinds of "meh"
  def self.batch_create(params)
    case params[:batch_type]
    when 'tags'
      batch_create_from_tags(params[:keyword_id], params[:klass], params[:loan_id])
    when 'pinboard'
      batch_create_from_pinboard(params[:loan_id], params[:project_id], params[:user_id], params[:klass])
    when 'collection_object_filter'
      batch_create_from_collection_object_filter(
        params[:loan_id],
        params[:project_id],
        params[:user_id],
        params[:collection_object_query])
    end
  end

  # @return [Hash]
  def self.batch_move(params)
    return false if params[:loan_id].blank? || params[:disposition].blank? || params[:user_id].blank? || params[:date_returned].blank?

    a = Queries::CollectionObject::Filter.new(params[:collection_object_query])
    return false if a.all.count == 0

    moved = []
    unmoved = []

    begin
      a.all.each do |co|
        new_loan_item = nil

        # Only match open loan items
        if b = LoanItem.where(disposition: nil).find_by(loan_item_object: co, project_id: co.project_id)

          new_loan_item = b.close_and_move(params[:loan_id], params[:date_returned], params[:disposition], params[:user_id])

          if new_loan_item.nil?
            unmoved.push b
          else
            moved.push new_loan_item
          end
        end
      end

    rescue ActiveRecord::RecordInvalid => e
     # raise e
    end

    return { moved:, unmoved: }
  end

  # @param param[:collection_object_query] required
  #
  # Return all CollectionObjects matching the query. Does not yet work with OtuQuery
  def self.batch_return(params)
    a = Queries::CollectionObject::Filter.new(params[:collection_object_query])
    return false if a.all.count == 0

    returned = []
    unreturned = []

    begin
      a.all.each do |co|
        if b = LoanItem.where(disposition: nil).find_by(loan_item_object: co, project_id: co.project_id)
          begin
            b.update!(disposition: params[:disposition], date_returned: params[:date_returned])
            returned.push b
          rescue ActiveRecord::RecordInvalid
            unreturned.push b
          end
        end
      end
    end
    return {returned:, unreturned:}
  end

  def close_and_move(to_loan_id, date_returned, disposition, user_id)
    return nil if to_loan_id.blank?

    new_loan_item = nil
    LoanItem.transaction do
      begin
        update!(date_returned:, disposition:)

        new_loan_item = LoanItem.create!(
          project_id:,
          loan_item_object:,
          loan_id: to_loan_id
          )

      rescue ActiveRecord::RecordInvalid => e
        #raise e
      end
    end
    new_loan_item
  end

  def self.batch_create_from_collection_object_filter(loan_id, project_id, user_id, collection_object_filter)
    created = []
    query = Queries::CollectionObject::Filter.new(collection_object_filter)
    LoanItem.transaction do
      begin
        query.all.each do |co|
          i = LoanItem.create!(loan_item_object: co, by: user_id, loan_id:, project_id:)
          if i.persisted?
            created.push i
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        # raise e
      end
    end
    return created
  end

  def self.batch_create_from_tags(keyword_id, klass, loan_id)
    created = []
    LoanItem.transaction do
      begin
        if klass
          klass.constantize.joins(:tags).where(tags: {keyword_id:}).each do |o|
            created.push LoanItem.create!(loan_item_object: o, loan_id:)
          end
        else
          Tag.where(keyword_id:).where(tag_object_type: ['Container', 'Otu', 'CollectionObject']).distinct.all.each do |o|
            created.push LoanItem.create!(loan_item_object: o.tag_object, loan_id:)
          end
        end
      rescue ActiveRecord::RecordInvalid
        return false
      end
    end
    return created
  end


  def self.batch_create_from_pinboard(loan_id, project_id, user_id, klass)
    return false if loan_id.blank? || project_id.blank? || user_id.blank?
    created = []
    LoanItem.transaction do
      begin
        if klass
          klass.constantize.joins(:pinboard_items).where(pinboard_items: {user_id:, project_id:, pinned_object_type: klass}).each do |o|
            created.push LoanItem.create!(loan_item_object: o, loan_id:)
          end
        else
          PinboardItem.where(project_id:, user_id:, pinned_object_type: ['Container', 'Otu', 'CollectionObject']).all.each do |o|
            created.push LoanItem.create!(loan_item_object: o.pinned_object, loan_id:)
          end
        end
      rescue ActiveRecord::RecordInvalid
        return false
      end
    end
    return created
  end

  protected

  # Whether this class of objects is in fact loanable, not
  # whether it's on loan or not.
  def object_loanable_check
    loan_item_object && loan_item_object.respond_to?(:is_loanable?)
  end

  # Code, not out-on-loan check!
  def loan_object_is_loanable
    if !persisted? # if it is, then this check should not be necessary
      if !object_loanable_check
        errors.add(:loan_item_object, 'is not loanble')
      end
    end
  end

  def total_provided_only_when_otu
    errors.add(:total, 'only providable when item is an OTU.') if total && loan_item_object_type != 'Otu'
  end

  # Is not already in a loan item if CollectionObject/Container
  def available_for_loan
    if !persisted? # if it is, then this check should not be necessary
      if object_loanable_check
        if loan_item_object_type == 'Otu'
          true
        else
          if loan_item_object.on_loan? # takes into account Containers!
            errors.add(:loan_item_object, 'is already on loan')
          end
        end
      end
    end
  end

end
