module Housekeeping::SharedAttributeScopes

#def self.included(base)

#  base.class_eval do 

#    byebug
#    if self.columns.map(&:name).include?('name')
#      def named_similarly_to(object)
#        where(['name LIKE ? or name LIKE ?', "#{object.name}%", "%#{object.name}%"])
#      end

#      def name_starting_with(letter)
#        where(['name LIKE ?', letter]) 
#      end 
#    end
#  end

#end




end

