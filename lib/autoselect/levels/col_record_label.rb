# lib/autoselect/levels/col_record_label.rb
# record_label / record_label_html for the TaxonName CoL levels
# (catalogue_of_life, col_valid_name): the CoL name followed by its original
# author+year.
module Autoselect::Levels::ColRecordLabel

  def record_label(record)
    [record.cached.to_s.presence, col_author_year(record)]
      .compact
      .join(' ')
  end

  def record_label_html(record, term = nil)
    [record.cached.to_s.presence, col_author_year(record)]
      .compact
      .map { |part| ERB::Util.html_escape(part) }
      .join(' ')
  end

  private

  # The display author+year for a CoL result.
  #
  # CoL renders a recombination's authorship as the original (basionym)
  # author+year wrapped in parens, followed by the combination authorship, e.g.
  # "(Chatton, 1925) Whittaker & Margulis, 1978". Per ICZN convention we show
  # only the original author+year, keeping the parens that signal the
  # recombination. A name described in its original genus has no leading
  # parenthetical and is shown verbatim, e.g. "Linnaeus, 1758".
  #
  # Other codes cite both authors, e.g. botanical "(Moench) Voss", so a name
  # whose CoL code is known and not zoological is shown verbatim too. (No
  # code is treated as zoological, as in Vendor::Colrapi.rank_class_for.)
  #
  # @return [String, nil]
  def col_author_year(record)
    ext = record._col_extension
    return nil unless ext

    authorship = ext[:col_authorship].presence
    return nil unless authorship

    code = ext[:col_code].presence
    return authorship if code && code != 'zoological'

    if (leading_parenthetical = authorship[/\A\([^)]*\)/])
      leading_parenthetical
    else
      authorship
    end
  end

end
