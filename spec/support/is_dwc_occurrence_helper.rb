module IsDwcOccurrenceHelper
  include ValidFactoryHelper

  def direct_is_dwc_occurrence_classes
    Rails.application.eager_load!

    ApplicationRecord.descendants
      .select { |klass| klass.included_modules.include?(Shared::IsDwcOccurrence) }
      .reject { |klass| klass.superclass&.included_modules&.include?(Shared::IsDwcOccurrence) }
      .reject(&:abstract_class?)
      .reject { |klass| klass.name.start_with?('Test', 'Unsupported') }
      .sort_by(&:name)
  end

  def direct_is_dwc_occurrence_class_names
    direct_is_dwc_occurrence_classes.map(&:name)
  end
end
