class Utilities::Hierarchy

  # Objects (nodes) can have attributes
  #
  #   id
  #   parent_id
  #   label
  #   url
  #   weight
  #   klass

  attr_accessor :nodes
  attr_accessor :node_map
  attr_accessor :hierarchy

  # inferred if root is not  provided
  attr_accessor :root_nodes

  # ID of the 
  attr_accessor :root

  attr_accessor :observed

  def initialize(objects: [], root_id: nil, match: nil )
    @root = root_id
    @nodes = objects 
    @node_map = nodes.inject({}) {|hsh, n| hsh[n.id] = n; hsh}
  end

  def hierarchy
    @hierarchy ||= build_hierarchy
  end

  def build_hierarchy
    @hierarchy = {}

    nodes.each do |n|

      @hierarchy[n.id] = []
      if p = @hierarchy[n.parent_id]
        p.push n.id
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
    z = "  " * level + "ID: #{node_id} #{node_map[node_id].label}\n"
    # puts z
    result.push z #  += z
    hierarchy[node_id]&.each do |child|
      result += draw(child, level + 1) 
    end
    result
  end

  def to_s
    s = [] 
    root_nodes.each do |id|
      s += draw(id, 0)
    end
    s
  end

end
