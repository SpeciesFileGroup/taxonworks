module SourcesHelper

  def self.source_tag(source)
    return nil if source.nil?
    source.cached ? source.cached : "WARNING CACHE NOT BUILT ADMIN TEST"
  end

  def source_tag(source)
    SourcesHelper.source_tag(source)
  end

end
