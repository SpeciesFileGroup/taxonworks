module Shared::ImmutableBoolean
  extend ActiveSupport::Concern

  class_methods do
    def immutable_boolean(*attrs)
      names = attrs.map!(&:to_s)

      before_update do
        names.each do |attr|
          next unless will_save_change_to_attribute?(attr)
          errors.add(attr, "is immutable and cannot be changed")
          throw :abort
        end
      end

      define_method :update_columns do |h|
        keys = h.keys.map!(&:to_s)
        if (keys & names).any?
          raise ActiveRecord::ReadOnlyRecord, "immutable attributes: #{(keys & names).join(', ')}"
        end
        super(h)
      end

      mod = Module.new do
        define_method :update_all do |updates|
          if (updates.is_a?(Hash) && (updates.keys.map!(&:to_s) & names).any?) ||
             (updates.is_a?(String) && names.any? { |a| updates =~ /\b#{Regexp.escape(a)}\s*=/i })
            raise ArgumentError, "immutable attributes: #{names.join(', ')}"
          end
          super(updates)
        end
      end

      singleton_class.class_eval do
        define_method(:all) { super().extending(mod) }
        define_method(:where) { |*a| super(*a).extending(mod) }
        define_method(:unscoped) { |*a,&b| super(*a,&b).extending(mod) }
      end
    end
  end
end