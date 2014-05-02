module Utilities::Files

  def self.lines_per_file(files)
    puts "Lines per file: "
    files.each do |f|
      puts `wc -l #{f}`
    end
  end


end
