# Facilitate sorting and rendering objects that have an id and parent_id.
class Utilities::Hierarchy

  # Objects (nodes) can have attributes
  #
  #   id
  #   parent_id
  #   label
  #   url    * not implemented
  #   weight * not implemented
  #   klass  * not implements
  #   alias  * alternative label

  # @return Array
  #   of objects with interface of properties above
  attr_accessor :nodes

  # @return Hash
  #   { node_id => object, ... }
  attr_accessor :node_map

  # @return Hash
  #   {id => [child ids], id2 => [] }
  #   Not really a hierarchy, just a parent/child lookup
  attr_accessor :hierarchy

  # @return Array
  #  inferred root ids, not used when `root` provided
  attr_accessor :root_nodes

  # @return Array
  #  asserted root ids
  attr_accessor :root

  # @return Array
  #   memoized list of node ids
  attr_accessor :observed

  # @return Array
  #   node_ids to be flagged as matched.
  #  permits return a simple true/false property in the result
  attr_accessor :match

  def initialize( params = {} )
    @root = params[:root_id]
    @nodes = params[:objects]
    @match = params[:match] || []
    @node_map = nodes.inject({}) {|hsh, n| hsh[n.id] = n; hsh}
  end

  def hierarchy
    @hierarchy ||= build_hierarchy
  end

  def build_hierarchy
    @hierarchy = {}

    nodes.each do |n|
      @hierarchy[n.id] = []
    end

    nodes.each do |n|
      if parent_id = node_map[n.id]&.parent_id
        @hierarchy[parent_id]&.push(n.id)
      end
    end

    @hierarchy
  end

  def observed
    @observed ||= @node_map.keys
  end

  def root_nodes
    @root_nodes ||= root ? [root] : hierarchy.keys.select{|id| !observed.include?( @node_map[id]&.parent_id )  }
    @root_nodes = [nodes.first.id] if @root_nodes.empty?
    @root_nodes
  end

  def draw(node_id, level = 0, result = [])
    z = '  ' * level + "ID: #{node_id} #{node_map[node_id].label}\n"
    # puts z
    result.push z #  += z
    hierarchy[node_id]&.each do |child|
      result += draw(child, level + 1)
    end
    result
  end

  def draw(node_id, level = 0, result = "")
    z = '  ' * level + node_map[node_id].label
    z << '*' if match? && matched?(node_id)
    z << "\n"

    result += z
    hierarchy[node_id]&.each do |child|
      result += draw(child, level + 1)
    end
    result
  end

  def build(node_id, level = 0, result = [])
    a = [node_id, node_map[node_id].label, (node_map[node_id].respond_to?(:alias) ? node_map[node_id].alias : nil), level]
    a.push matched?(node_id) if match?
    result.push a
    hierarchy[node_id]&.each do |child|
      result += build(child, level + 1)
    end
    result
  end

  def to_a
    a = []
    root_nodes.each do |id|
      a += build(id, 0)
    end
    a
  end

  def to_s
    s = ''
    root_nodes.each do |id|
      s += draw(id, 0)
    end
    s
  end

  def match?
    !match.empty?
  end

  def matched?(node_id)
    match.include?(node_id)
  end

end
