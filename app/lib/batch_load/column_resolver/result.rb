# Stores the attributes of a Column Resolver result
module BatchLoad::ColumnResolver

  class Result

    # The singular resolved item
    attr_accessor :item

    # When more than one item is found they are listed here.
    # In practice this should be limited to the first 10 or so,
    # rather than all potential matches.
    attr_accessor :items

    # When the resolver can not identify a single record the
    # reasons can be added here
    attr_accessor :error_messages

    def initialize
      @error_messages = []
      @items = []
    end

    # @return [Boolean]
    def resolvable?
      item && error_messages.size == 0 && items == [] # a little redundant, but keep it safe
    end

    # @return [Boolean]
    def multiple_matches?
      items.size > 0
    end

    # @return [Boolean]
    def no_matches?
      item.nil? and items.empty?
    end

    # @param [Object] objects
    # @return [Array]
    def assign(objects)
      if objects.class == Array
        if objects.size == 1
          @item = objects.first
          @items = []
        else
          @items = objects
          @item = nil
        end
      else
        @item = objects
      end
    end
  end
end
