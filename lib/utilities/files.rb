module Utilities::Files

  def self.lines_per_file(files)
    puts "Lines per file: "
    files.each do |f|
      puts `wc -l #{f}`
    end
  end

  # @return [Array [Boolean, String]]
  def self.recognized_batch_file_type?(file)
    mimetype = `file -b "#{file.path}"`.gsub(/\n/, '')
    case mimetype
    when /utf-8/i, /ascii/i, /bibtex/i
      return [true, mimetype]
    else
      return [false, mimetype]
    end
  end


end
