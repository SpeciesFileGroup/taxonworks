require 'rails_helper'

describe 'Utilities::Files' do

  # Assumes /tmp exists
  specify '.replace' do
    a = '/tmp/a.txt'
    b = '/tmp/b.txt'
    File.open(a, 'w') { |f| f.write("a") }
    File.open(b, 'w') { |f| f.write("b") }

    begin
      Utilities::Files.replace(a, b)
      expect(File.read(a)).to match('b') 
      expect(File.exist?(b)).to be_falsey
    ensure
      File.delete(a) if File.exist?(a)
      File.delete(b) if File.exist?(b)
    end
  end

end
