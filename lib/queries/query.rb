# See
#  http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
#  https://github.com/rails/arel
#  http://robots.thoughtbot.com/using-arel-to-compose-sql-queries
#  https://github.com/rails/arel/blob/master/lib/arel/predications.rb
#  And this:
#    http://blog.arkency.com/2013/12/rails4-preloading/
#    User.includes(:addresses).where("addresses.country = ?", "Poland").references(:addresses)
#  
# TODO: Define #all as a stub (Array or AR)
#
class Queries::Query
  include Arel::Nodes

  attr_accessor :query_string
  attr_accessor :terms
  attr_accessor :project_id

  # limit based on size and potentially properties of terms
  attr_accessor :dynamic_limit

  def initialize(string, project_id: nil, **keyword_args)
    @query_string = string
    @project_id = project_id
    build_terms
  end

  # @return [Array]
  #   the results of the query as an *array*
  def result
    []
  end

  def scope
    where('1 = 2') 
  end

  def terms=(string)
    @query_string = string
    build_terms
    terms 
  end

  def start_wildcard
    '%' + query_string 
  end

  def end_wildcard
    query_string + '%'
  end

  # @return [String]
  def start_and_end_wildcard
    '%' + query_string + '%'
  end

  def terms
    @terms ||= build_terms
  end

  def integers
    query_string.split(/\s+/).select{|t| Utilities::Strings.is_i?(t)}
  end

  # @return [Array]
  def wildcard_wrapped_integers
    integers.collect{|i| "%#{i}%"}
  end

  def strings
    a = query_string.split(/\s+/).select{|t| !(t =~ /\d+/)} 
    a.empty? ? [ ] : a
  end

  def alphabetic_strings
    a = query_string.gsub(/[^a-zA-Z]/, ' ').split(/\s+/).select{|t| !(t =~ /\d+/)} 
    a.empty? ? [  ] : a
  end

  def years
    integers.select{|a| a =~ /\b\d{4}\b/}.map(&:to_s).compact
  end

  # @return [Boolean]
  #   true if the query string only contains integers
  def only_integers?
    !(query_string =~ /[^\d\s]/i) && !integers.empty? 
  end

  # @return [Array]
  #   if 5 or fewer strings, those strings wrapped in wildcards, else none
  def fragments
    if strings && strings.count < 6
      strings.collect{|a| "%#{a}%"}
    else
      []
    end
  end

  # Replace with a full text indexing approach
  def build_terms
    @terms = [end_wildcard, start_and_end_wildcard]  # query_string.split(/\s+/).compact.collect{|t| [t, "#{t}%", "%#{t}%"]}.flatten
  end

  def no_digits 
    query_string.gsub(/\d/, '').strip
  end

  def dynamic_limit
    limit = 10 
    case query_string.length
    when 0..3
      limit = 20 
    else
      limit = 100 
    end
    limit
  end

  def pieces
    query_string.split(/\s+/)
  end

  # generic multi-use bits

  def parent_child_join
    table.join(parent).on(table[:parent_id].eq(parent[:id])).join_sources # !! join_sources ftw
  end

  # Match at two levels, for example, 'wa te" will match "Washington Co., Texas"
  def parent_child_where
    a,b = query_string.split(/\s+/, 2)
    return table[:id].eq(-1) if a.nil? || b.nil?
    table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
  end

  # @return [Query, nil]
  #   used in or_clauses
  def with_id
    if integers.any?
      table[:id].eq_any(integers)
    else
      nil
    end
  end

  # @return [Query, nil]
  #   used in or_clauses, match on id only if integers alone provided.
  def only_ids
    if only_integers?
      with_id
    else
      nil
    end 
  end

  def named
    table[:name].matches_any(terms)
  end

  def exactly_named
    table[:name].eq(query_string)
  end

  def parent 
    table.alias 
  end

  # TODO: nil/or clause this
  def with_project_id
    if project_id 
      table[:project_id].eq(project_id)
    else
      nil      
    end
  end

  def identifier_table
    Identifier.arel_table
  end

  # @return [Arel::Nodes::Grouping]
  def with_identifier_like
    a = [ start_and_end_wildcard ]
    a = a + wildcard_wrapped_integers
    identifier_table[:cached].matches_any(a)
  end

  def with_identifier
    identifier_table[:cached].eq(query_string)
  end

  # @return [ActiveRecord::Relation, nil]
  # cached matches full query string wildcarded
  def cached
    if !terms.empty?
      table[:cached].matches_any(terms)
    else
      nil
    end
  end

  def combine_or_clauses(clauses)
    clauses.compact!
    raise TaxonWorks::Error, 'combine_or_clauses called without a clause, ensure at least one exists' unless !clauses.empty?
    a = clauses.shift
    clauses.each do |b|
      a = a.or(b)
    end
    a
  end

  # @return [Array]
  #   default the autocomplete result to all
  def autocomplete
    all.to_a
  end

end
