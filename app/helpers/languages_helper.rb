module LanguagesHelper

  def language_tag(language)
    return nil if language.nil?
    language.english_name
  end

end
