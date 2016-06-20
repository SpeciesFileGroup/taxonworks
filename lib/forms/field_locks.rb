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

    def locked?(object_name, method)
      (locks[object_name.to_s] && locks[object_name.to_s][method.to_s].to_s == '1') ? true : false
    end

    def has_locks?
      locks.keys.any?
    end

    def to_params
      locks
    end

    def resolve(object_name, method, value)
      return nil if value.nil?
      if locked?(object_name.to_s, method.to_s)
        value
      else
        nil
      end
    end

    def lock(object_name, method)
      locks[object_name] ||= {}
      locks[object_name].merge!(method => 1)
    end

    def unlock(object_name, method)
      locks[object_name].delete(method)
    end



  end
end
