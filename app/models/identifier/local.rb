class Identifier::Local < Identifier 
  belongs_to :namespace
  validates  :namespace, presence: true

  after_validation :set_cached_value

  protected

  def set_cached_value
    if errors.empty?
      cached = Namespace.name + " " + identifier.to_s
    end
  end



end
