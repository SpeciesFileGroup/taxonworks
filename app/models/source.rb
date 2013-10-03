class Source < ActiveRecord::Base
  validate :bibtex_format
  validate :not_empty

  protected
  def bibtex_format
    #
  end

  protected
  def source_to_bibtex
    false   # What goes in this method? Some magic, I expect.
  end

  protected
  def not_empty
    # a source must have content in some field

  end


end
