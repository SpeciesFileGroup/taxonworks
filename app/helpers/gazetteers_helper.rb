module GazetteersHelper
  def gazetteer_link(gazetteer, link_text = nil)
    return nil if gazetteer.nil?
    link_text ||= gazetteer.name
    link_to(link_text, gazeteer)
  end
end
