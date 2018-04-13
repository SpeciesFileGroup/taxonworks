# TODO: This needs to be in /lib
class Utilities::CleanseFilename
=begin
   def initialize(invalid_character_regex)
    @invalid_character_regex = invalid_character_regex
  end
=end

  # downcase and replace all non-alphanumerics with '_'
  # @param [String] filename
  # @return [String]
  def self.call(filename)
    filename.to_s.downcase.gsub(/[^A-Za-z0-9\.]/, '_')

   #tmp = (filename.to_s.downcase).split('.')
   #if tmp.count == 2
   #   tmp[0].gsub(/[^A-Za-z0-9\.]/, '_') + '.' + tmp[1]
   #else
   # for i in 0..(tmp.length-1)
   #    name = tmp[i].gsub(/[^A-Za-z0-9\.]/, '_')
   #  end
   #  name.join('_') + '.' + tmp.last
   #end
   end
end
