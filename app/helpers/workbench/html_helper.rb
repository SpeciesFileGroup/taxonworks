# Basic, non model dependent helpers that inject HTML, 
# these should all depend on Rails helpers, if they don't
# they should go into Utilities
module Workbench::HtmlHelper

  # TODO: see also highlight()
  # @return [String, nil]
  #   markup a string, skipping matches inside HTML tags (e.g. attribute values)
  def mark_tag(string, term)
    return nil if string.nil?
    return string if term.blank?
    t = Regexp.escape(term)

    string.split(/(<[^>]*>)/).map { |piece|
      piece.start_with?('<') ? piece : piece.gsub(/(#{t})/i) { content_tag(:mark, $1) }
    }.join.html_safe
  end

end

