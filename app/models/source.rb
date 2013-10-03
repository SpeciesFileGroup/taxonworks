class Source < ActiveRecord::Base
  validate :bibtex_format
  protected
  def bibtex_format
    #
  end

  protected
  def source_to_bibtex
    false   # What goes in this method? Some magic, I expect.
  end



end
