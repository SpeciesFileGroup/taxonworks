module Forms
  class FieldLocks
   
    # {
    #   object_name: [method_name, method_name1]
    # }
    attr_accessor :locks

    # @param[ActiveRecord] a instance of some ActiveRecord model
    def initialize(params = {})
      @locks = params
    end

    def locked?(object_name, method)
      has_locks? && locks["locks"][object_name.to_s] && locks["locks"][object_name.to_s][method.to_s]
    end

    def has_locks?
      !locks["locks"].blank?
    end

    def to_params
      locks
    end

    def resolve(object_name, method, value)
      return nil if value.nil?
      if locked?(object_name, method)
        value
      else
        nil
      end
    end

  end
end
