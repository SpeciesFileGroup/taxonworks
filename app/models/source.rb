class Source < ActiveRecord::Base
  validate :not_empty

  protected
  def not_empty
    # a source must have content in some field
  end

end
