module Utilities::Strings

  def self.nil_strip(string) # string should have content or be empty
    if !string.nil?
      string.squish!
      string = nil if string == ''
    end
    string
  end
end