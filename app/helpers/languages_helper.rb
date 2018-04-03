module LanguagesHelper

  def language_tag(language)
    return nil if language.nil?
    language.english_name
  end

  # There is no path, we fake it.
  def language_link(language)
    language.english_name
  end

end
