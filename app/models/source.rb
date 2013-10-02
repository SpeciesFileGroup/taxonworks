class Source < ActiveRecord::Base
  validate :bibtex_format
  protected
  def bibtex_format
    #
  end

end
