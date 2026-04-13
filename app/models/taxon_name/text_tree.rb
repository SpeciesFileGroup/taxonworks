# See https://github.com/gbif/text-tree.
#
# Implements $,=,≡.
# Does not implement comments (#) or {} extensions.
#
# In the console:
#
#   puts Protonym.last.text_tree
#
#   or to combine multiple names in a tree
#
#   puts Protonym.text_tree( Protonym.limit(3).to_a )
#
module TaxonName::TextTree
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    # @return String
    def text_tree(names)
      objects = names.collect{|n| n.send(:text_tree_nodes)}.flatten.uniq
      render_text_tree(objects:)
    end

    # @return String
    def render_text_tree(objects: [])
      a = ::Utilities::Hierarchy.new(objects: )
      a.to_s
    end
  end

  def text_tree
    TaxonName.text_tree([self])
  end

  private

  # @return ::Utilities::Hierarchy::Node.new
  #   with text_tree synonym (=) decoration if invalid
  def to_node
    if cached_is_valid
      ::Utilities::Hierarchy::Node.new(
        id,
        parent_id,
        [cached, cached_author_year, "[#{rank_name}]" ].compact.join(' '),
        nil,
        nil,
        nil,
        nil
      )
    else
      ::Utilities::Hierarchy::Node.new(
        id,
        cached_valid_taxon_name_id,
        ['=' + cached_original_combination, [cached_author, cached_nomenclature_date.year].join(', '), "[#{rank_name}]"].compact.join(' '),
        nil,
        nil,
        nil,
        nil
      )
    end
  end

  # @return ::Utilities::Hierarchy::Node.new
  #   with text_tree basionym + homotypic decoration
  def basionym_node
    if cached_original_combination
      ::Utilities::Hierarchy::Node.new(
        'b' + id.to_s,
        self.id,
        ['≡$' + cached_original_combination, [cached_author, cached_nomenclature_date.year].join(', '), "[#{rank_name}]" ].compact.join(' '),
        nil,
        nil,
        nil,
        nil
      )
    else
      nil
    end
  end

  def synonym_nodes
    nodes = []
    synonyms.where(type: 'Protonym').order(:cached, :cached_valid_taxon_name_id).select{|a| a.id != id}.each do |s|
      nodes.push s.send(:to_node)
      s.combinations.order(:cached, :cached_valid_taxon_name_id).select{|a| a.cached != s.cached}.each do |t|
        nodes.push t.send(:to_node)
      end
    end
    nodes
  end

  def text_tree_nodes
    objects = self_and_ancestors.unscope(:order).where.not(name: 'Root').collect{|a| a.send(:to_node)}
    objects.push basionym_node if cached_original_combination
    combination_nodes = combinations.order(:cached, :cached_valid_taxon_name_id).select{|a| cached != a.cached}.collect{|b| b.send(:to_node)}
    objects += combination_nodes + synonym_nodes
  end

end
