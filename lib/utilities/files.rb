module Utilities::Files

  # @param [Array] files
  def self.lines_per_file(files)
    puts 'Lines per file: '
    files.each do |f|
      puts `wc -l #{f}`
    end
  end

  # @param [String] file
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


  # @return [Boolean]
  # @param file_to_replace a file path, this file will be destroyed
  # @param file_to_keep a file path, this file will named the name of file_to_replace
  def self.replace(original_file, new_file)
    return false unless File.exist?(original_file) && File.exist?(new_file)
    fo = original_file
    ft = fo + '.tmp'

    begin
      File.rename(fo, ft)
      File.rename(new_file, fo)

      File.delete(ft) if File.exist?(ft)
    rescue
      return false
    ensure
      unless File.exist?(original_file) # as we exit we must have a file there
        File.rename(ft, original_file)
      end
    end
    true
  end


end
