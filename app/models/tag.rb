class Tag < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::AttributeAnnotations

  acts_as_list scope: [:keyword_id]

  belongs_to :keyword
  belongs_to :tag_object, polymorphic: true

  validates :tag_object, presence: true
  validates :keyword, presence: true
  validate :keyword_is_allowed_on_object, :object_can_be_tagged_with_keyword

  validates_uniqueness_of :keyword_id, scope: [:tag_object_id, :tag_object_type]

  def tag_object_class
    tag_object.class
  end

  def self.find_for_autocomplete(params)
    # where('name LIKE ?', "#{params[:term]}%")
    # todo: @mjy below code is running but not giving results we want
    terms = params[:term].split.collect { |t| "'#{t}%'" }.join(' or ')
    joins(:keyword).where('controlled_vocabulary_terms.name like ?', terms) # "#{params[:term]}%" )
  end

  # @return [TagObject]
  #   alias to simplify reference across classes 
  def annotated_object
    tag_object
  end

  # the column name containing the attribute name being annotated
  def self.annotated_attribute_column
    :tag_object_attribute
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  def keyword_is_allowed_on_object
    return true if keyword.nil? || tag_object.nil? || !keyword.respond_to?(:can_tag)
    if !keyword.can_tag.include?(tag_object.class.name)
      errors.add(:keyword, "this keyword class (#{tag_object.class}) can not be attached to a #{tag_object_type}")
    end
  end

  def object_can_be_tagged_with_keyword
    return true if keyword.nil? || tag_object.nil? || !tag_object.respond_to?(:taggable_with)
    if !tag_object.taggable_with.include?(keyword.class.name)
      errors.add(:tag_object, "this tag_object_type (#{tag_object.class}) can not be tagged with this keyword class (#{keyword.class})")
    end
  end

end
