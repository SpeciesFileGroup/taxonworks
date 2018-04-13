module Forms
  class FieldLocks

    # {
    #   object_name: [method_name, method_name1]
    # }
    attr_accessor :locks

    # @param[ActiveRecord] a instance of some ActiveRecord model
    def initialize(params = {})
      @locks = params
      @locks ||= {}
    end

    # @param [Object] object_name
    # @param [String, Symbol] method
    # @return [Boolean]
    def locked?(object_name, method)
      (locks[object_name.to_s] && locks[object_name.to_s][method.to_s].to_s == '1') ? true : false
    end

    # @return [Boolean]
    def has_locks?
      locks.keys.any?
    end

    # @return [Hash]
    def to_params
      locks
    end

    # @param [Object] object_name
    # @param [String, Symbol] method
    # @param [Object] value
    # @return [Object, nil]
    def resolve(object_name, method, value)
      return nil if value.nil?
      if locked?(object_name.to_s, method.to_s)
        value
      else
        nil
      end
    end

    # @param [Object] object_name
    # @param [String, Symbol] method
    # @return [Object]
    def lock(object_name, method)
      locks[object_name] ||= {}
      locks[object_name].merge!(method => 1)
    end

    # @param [Object] object_name
    # @param [String, Symbol] method
    # @return [Object]
    def unlock(object_name, method)
      locks[object_name].delete(method)
    end

  end
end
