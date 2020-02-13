
# author Matt Yoder
# initiated at dbhack1, nescent, 2009

# This is largerly proof of concept code and was written over the course of 2 days.  There is a lot of
# redundancy that needs to be dealt with and some major refactoring of the model.  The ultimate goal is to 
# create a module for BioRuby.

# The basic idea is to use a streaming (SAX? like) library to read a NeXML file, mapping it to a simple
# class heirarchy that represents the major components in NeXML.  NeXML element attributes are stored in a hash.

# See nexml_test.rb for tests and example usage

# TODO
# Besides the refactoring/rewrite this present code need:
# - finish the parsing of the charactr matrix
# - integrate BioRuby seq objects for molecular data
# - create a writer/serializer
# -  

module Nexml

require "rexml/streamlistener"
require 'rexml/document'

include REXML

  class NexmlError < StandardError
  end

  # code to read the file, the lexer/parser

  class Handler
    def initialize(obj)
      @obj = obj
    end
    include REXML::StreamListener
    
    # hit at the start of an element tag  
    def tag_start name, attrs
      # puts "processing: #{name}"
    
      # These are more or less equivalent to tokens, 
      # they could likely be abstracted to a single
      # klass-like calls
        case name
        when "otus" # it's always a new object
          @obj.current_obj = @obj.new_otus(attrs)
          @obj.current_otus = @obj.current_obj 
        when "otu" # it's always in a otus block 
          @obj.current_obj =  @obj.new_otu(attrs)  
        when "characters"
          @obj.current_obj = @obj.new_characters(attrs)
          @obj.current_characters = @obj.current_obj 
        when "char" 
          @obj.current_obj =  @obj.new_char(attrs)  
        when "trees"  
          @obj.current_obj = @obj.new_trees(attrs)
          @obj.current_trees = @obj.current_obj 
        when "tree"
          @obj.current_obj = @obj.new_tree(attrs)  
          @obj.current_tree = @obj.current_obj 
        when "node"
          @obj.current_obj = @obj.new_node(attrs) 
        when "edge"  
          @obj.current_obj = @obj.new_edge(attrs) 
        else
          # necessary? 
        end 
    end
   
    # in between elements  
    def text text
      t = text.strip
      # *** NOTE *** 
      # need to test to see that this doesn't have problems with embedded elements like so
      # <foo>alskfjaslkdfjlasfj <br/> </foo>
      @obj.current_obj.text = t if @obj.current_obj && t.size > 0 
    end

    # TODO: likely needs to be extended and closed properly with a tag_end token as well

  end # end Handler

  # base class for all Document objects
  class DummyBase
    attr_accessor :attributes, :text 
    def initialize(opts)
      @text = nil 
      @attributes = {} 
      @attributes = opts[:attrs] if opts[:attrs] 
      @text = opts[:text] if opts[:text] 
      true 
    end 
  
    def attribute(a)
      @attributes[a]
    end
  end # end DummyBase

# model of the NeXML file
class Document < DummyBase
  
  # these three are the top level grouping classes 
  attr_accessor :characters, :otus, :trees

  # stores the present state as we stream through the file, these may not all be necessary and can likely 
  # be abstracted down to a single :current_parent_object
  attr_accessor :current_matrix, :current_trees, :current_tree, :current_characters,  :current_otus, :current_obj

  def initialize(options = {}) 
    @opt = {
      :file => false,
      :url => false 
    }.merge!(options)
    @otus, @characters, @trees = [],[],[]
    @current_obj = nil
    @current_matrix, @current_tree, @current_trees, @current_otus, @current_characters = nil,nil, nil, nil, nil

    # require a file or a URL
    raise Nexml::NexmlError, "supply ONLY one of :file or :url" if @opt[:file] && @opt[:url]
      
    @nexml = ''
    if @opt[:file]
      @nexml = @opt[:file]
    elsif @opt[:url] 
      @nexml = Net::HTTP.get_response(URI.parse(@opt[:url])).body
    else
      raise Nexml::NexmlError, "supply one of :file or :url" if !@opt[:file] && !@opt[:url]
    end 

    @attributes = {}
    
    # do the work 
    REXML::Document.parse_stream(@nexml, Handler.new(self))
    true 
  end

  # more redundancy, can likely collapse these down to klass type methods?
  
  # setters 
  def new_otus(attrs)
    otus = Otus.new(:attrs => attrs)
    self.otus.push(otus)
    otus 
  end

  def new_otu(attrs)
    otu = Otu.new(:attrs => attrs)
    self.current_otus.otus.push(otu)
    otu 
  end

  def new_characters(attrs)
    characters = Characters.new(:attrs => attrs)
    self.characters.push(characters)
    characters 
  end

  def new_char(attrs)
    chr = Char.new(:attrs => attrs)
    self.current_characters.chars.push(chr)
    chr 
  end

  def new_trees(attrs)
     trees = Trees.new(:attrs => attrs)
     self.trees.push(trees)
     trees  
  end

  def new_tree(attrs)
    tree = Tree.new(:attrs => attrs)
    self.current_trees.trees.push(tree)
    tree 
  end

  def new_node(attrs)
    node = Node.new(:attrs => attrs)
    self.current_tree.nodes.push(node)
    node 
  end

  def new_edge(attrs)
    node = Edge.new(:attrs => attrs)
    self.current_tree.edges.push(node)
    node 
  end

  # getters
  
  def otu_by_id(id)
    foo = self.all_otus.collect{|o| o.attribute('id')}
    self.all_otus[foo.index(id)] 
  end

  def tree_by_id(id)
    foo = self.all_trees.collect{|o| o.attribute('id')}
    self.all_trees[foo.index(id)] 
  end
  
  def all_otus
    @otus.inject([]){|sum, o| sum.push(o.otus)}.flatten
  end

  def all_chrs
    @characters.inject([]){|sum, o| sum.push(o.chars)}.flatten
  end

  def all_trees
    @trees.inject([]){|sum, o| sum.push(o.trees)}.flatten
  end


  
  # rest of the model

  class Otus < DummyBase
    attr_accessor :otus 
    def initialize(opts)
      @otus = [] 
      super
    end 
  end

  class Otu < DummyBase
    def initialize(opts)
     super
    end 
  end

  class Characters < DummyBase
    attr_accessor :chars
    def initialize(opts)
      @chars = [] 
      super
    end 
  end

  class Char < DummyBase
    def initialize(opts)
     super
    end 
  end

  class Trees < DummyBase
    attr_accessor :trees
    def initialize(opts)
      @trees = [] 
      super
    end 
  end

  # need to refact to allow for parent->child nodes
  class Tree < DummyBase
    attr_accessor :nodes, :edges
    def initialize(opts)
      super
      @nodes = []
      @edges = []
    end 

    # yuck 
    def root_node
      @nodes.each do |n|
        return n if n.attributes['root'] 
      end 
    end 

    def children_of_node(node)
      @children = []
      @edges.each do |e|
        @children.push(self.node_by_id(e.attributes['target'])) if (e.attributes['source'] ==  node.attributes['id'])
      end
      @children 
    end

    # make a big hash store to handle these
    def node_by_id(id)
      @nodes.each do |n|
        return n if n.attributes['id'] == id 
      end
    end

  # NOT WORKING - needs refactoring 
  def newick_string(node, string = '')
    @str = string
    nodes = self.children_of_node(node)
      nodes.each do |n|
        @str += self.otu_by_id(node.attributes['otu']).attributes['label']           
        self.newick_string(n, @str)
        @str += "," 
      end 

   #    case nodes.size
   #   when 0   
   #     @str += ""
   #   when 1 
   #    @str += ",(" 
   #   else 
   #     @str += ")"    
   #   end        
   
    @str 
  end
  end # end Tree

  # these two need to be internalize (perhaps within the tree)
  class Edge < DummyBase 
    def initialize(opts)
     super
    end 
  end
 
  class Node < DummyBase 
    def initialize(opts)
     super
    end 
  end

  # TODO

  class Matrix < DummyBase 
  end

  class Annotation
    # stub 
  end  

  class State < DummyBase 
    # stub 
  end

  class Coding < DummyBase 
  end


end # end Document

end # end modules

