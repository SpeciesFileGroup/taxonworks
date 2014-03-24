class CleanseFilename
  # downcase and replace all non-alphanumerics with '_'
  def call(filename)
    tmp = filename.split('.')
    if tmp.count == 2

    end
    if @invalid_character_regex
      filename.gsub(@invalid_character_regex, "_")
    else
      filename
    end
  end

end
