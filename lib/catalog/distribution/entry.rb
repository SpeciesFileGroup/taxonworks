# A Catalog::Entry has many entry items.  Together CatalogEntrys form a Catalog
# require 'catalog/entry'
  class ::Catalog::Distribution::Entry < ::Catalog::Entry
    
    def initialize(otus)
      super(otus) # object set to otus!
      true
    end
    
    def build
      from_self
      true
    end
    
    def to_html_method
      # :otu_catalog_entry_item_to_html
    end
    
    def from_self
      #object.each do |otu|
      # a = ::Otu.coordinate_otus(otu.id).load
      
      # scoping should be done outside this function !
      # a = ::Otu.descendant_of_taxon_name(otu.taxon_name_id).load #  coordinate_otus(otu.id).load
      
      a = object # an Array of Otus, predetermined at this point
      
      #      puts Rainbow(o.name + otu.taxon_name.cached).yellow
      
      current_collection_objects = CollectionObject.joins(:taxon_determinations).where(taxon_determinations: {position: 1, otu: a})
      asserted_distributions = AssertedDistribution.where(otu: a)
      type_materials = TypeMaterial.joins(protonym: [:otus]).where('otus.id' => a)
      
      #      a.each do |o|
      [current_collection_objects, asserted_distributions, type_materials].flatten.each do |c|
        @items << Catalog::Distribution::EntryItem.new(
          object: c,
          #            base_object: otu,
          citation: c.origin_citation,
          nomenclature_date: c.source&.nomenclature_date,
          #            current_target: entry_item_matches_target?(o, otu)
        )
      end
    end
    #    end
    # end
    
    # @return [Boolean]
    def entry_item_matches_target?(item_object, reference_object)
      item_object.id == reference_object.id
    end
    
    # @return Array
    #   may contain nil 
    def countries
      c = items.map(&:country).uniq.sort
    end
    
    def raw_data
      items.collect{|a| a.geographic_name_classification}.uniq
    end
    
    def data
      r = raw_data
      d = {} # country => [state => [county]]
      
      items.each do |i|
        
        c = i.country
        s = i.state
        y = i.county
        
        if !d.dig(c)
          d[c] = {}
        end
        
        if !d.dig(c,s)
          d[c][s] = {}
        end
        
        if !d.dig(c,s,y) 
          d[c][s][y] = nil
        end
      end
      
      d
    end
    
    # Includes County records
    def to_s_verbose
      d = data
      str = ''
      
      d.keys.sort{|a,b| (a || 'zzz') <=> (b || 'zzz')}.each do |c|
        str << ', ' unless str.size == 0
        str << (c.nil? ? 'UNPARSED' : c.to_s) 
        
        states = []
        semi = false
        
        d[c].keys.sort{|a,b| (a || 'zzz') <=> (b || 'zzz')}.each do |s|
          next if s.nil? && d[c][s] == {nil => nil}
          
          s1 = s.to_s.dup
          s1 = 'STATE' if s1 == ''
          
          z = d[c][s].keys.compact.sort
          if z.size > 0
            s1 << ': ' + z.join(', ')
            semi = true
          end
          
          states.push s1
        end
        
        if states.any?
          str << ' (' + states.join( semi ? '; ' : ', ') + ')'
        end
      end
      str << '.'
      
      str.gsub!(/,\sUNPARSED\.$/, '.')
      
      return nil if str == '.'
      str
    end
    
    def to_s
      d = data
      str = ''
      
      d.keys.sort{|a,b| (a || 'zzz') <=> (b || 'zzz')}.each do |c|
        str << ', ' unless str.size == 0
        str << (c.nil? ? 'UNPARSED' : c.to_s) 
        
        z = d[c].keys.compact.sort
        
        if z.size > 0
          str << ' (' + z.join(', ') + ')'
        end
      end
      str << '.'
      
      str.gsub!(/,\sUNPARSED\.$/, '.')
      
      return nil if str == '.'
      str
    end
    
  end
  
