# In theory this should work if we used the nulify_blanks gem. It does't.
#   ActiveRecord::Base.nilify_blanks
#
# via
#
# http://www.wenda.io/questions/60068/rails-force-empty-string-to-null-in-the-database.html
# https://github.com/rubiety/nilify_blanks/blob/master/lib/nilify_blanks.rb
module NilifyBlanks 
  extend ActiveSupport::Concern

  included do
    before_save :nilify_blanks
  end

  def nilify_blanks
    attributes.each do |column, value|
      next unless value.is_a?(String)
      next unless value.respond_to?(:blank?)
      write_attribute(column, nil) if value.blank?
    end
  end 

end

ActiveRecord::Base.send(:include, NilifyBlanks) 
