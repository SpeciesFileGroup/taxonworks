module Lib::Vendor::GnfinderHelper

  # @param gnfinder_name [ Array of Vendor::Gnfinder::Name]
  def gnfinder_matches_links(gnfinder_names, source)
    return nil if gnfinder_names.empty?

    r = []
    gnfinder_names.each do |n|
      s = link_to(n.cached, browse_nomenclature_task_path(taxon_name_id: n))
      if source
        s = quick_citation_tag(source.id, n, 'margin-small-right') + ' ' + s
      end
      r.push s
    end
    r.join(', ').html_safe
  end

end
