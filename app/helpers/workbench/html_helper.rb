# Basic, non model dependent helpers that inject HTML, 
# these should all depend on Rails helpers, if they don't
# they should go into Utilities
module Workbench::HtmlHelper

  # TODO: see also highlight()
  # @return [String, nil]
  #   markup a string
  def mark_tag(string, term)
    return nil if string.nil?
    return string if term.nil?
    t = Regexp.escape(term)

    # (?!>) Don't substitute if the next character is a closing paren
    string.gsub(/(#{t})(?!>)/i, content_tag(:mark, '\1')).html_safe
  end

end

