module SourcesHelper

  def self.source_tag(source)
    return nil if source.nil?
    source.cached ? source.cached : "WARNING CACHE NOT BUILT ADMIN TEST"
  end

  def source_tag(source)
    SourcesHelper.source_tag(source)
  end
  
  def sources_search_form
    render('/sources/quick_search_form')
  end

  # TODO: write helper methods
  # context 'source format variations' do
  #   # a valid source ibtex should support the following output formats
  #   skip 'authority string - <author family name> year'
  #   skip 'short string - <author short name (as little of the author names needed to differentiate from other authors within current project)> <editor indicator> <year> <any containing reference - e.g. In Book> <Short publication name> <Series> <Volume> <Issue> <Pages>'
  #   skip 'long string - <full author names> <editor indicator> <year> <title> <containing reference> <Full publication name> <Series> <Volume> <Issue> <Pages>'
  #   skip 'no publication long string -<full author names> <editor indicator> <year> <title> <containing reference> <Series> <Volume> <Issue> <Pages>'
  # end

end
