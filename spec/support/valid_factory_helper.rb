module ValidFactoryHelper
  def valid_factory_for_class(klass)
    matching_factories = FactoryBot.factories.select do |factory|
      next false unless factory.name.to_s.start_with?('valid_')

      # A valid factory can satisfy a target base class if it builds that
      # class itself or any STI subclass of it.
      factory.build_class <= klass
    rescue StandardError
      false
    end

    matching_factories.min_by { |factory| factory.name.to_s }
  end

  def valid_factory_for_type(type_name)
    valid_factory_for_class(type_name.constantize)
  end
end
