# Basic, non model dependent helpers that inject HTML,
# these should all depend on Rails helpers, if they don't
# they should go into Utilities
module Workbench::HtmlHelper

  # TODO: see also highlight()
  # @return [String, nil]
  #   markup a string, skipping matches inside HTML tags (e.g. attribute values)
  # @param html_safe [Boolean]
  #   pass false when the caller keeps building the result with plain
  #   String#+/+=  and applies .html_safe itself at the end - otherwise
  #   an already-safe return value here causes later unsafe appends to
  #   get HTML-escaped by ActiveSupport::SafeBuffer#+
  def mark_tag(string, term, html_safe: true)
    return nil if string.nil?

    s = if term.blank?
      string
    else
      t = Regexp.escape(term)
      string.split(/(<[^>]*>)/).map { |piece|
        next piece if piece.start_with?('<')

        # We split on the html entities content_tag could produce (though at
        # time of writing these could also come from user input).
        piece.split(/(&(?:amp|lt|gt|quot|\#39);)/).map { |chunk|
          chunk.start_with?('&') ? chunk : chunk.gsub(/(#{t})/i) { content_tag(:mark, $1) }
        }.join
      }.join
    end

    html_safe ? s.html_safe : String.new(s)
  end

end

