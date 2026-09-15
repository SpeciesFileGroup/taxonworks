module Workbench::AutoselectHelper

  # Renders the mount point for the Vue `AutoselectField` initializer
  # (`app/javascript/vue/initializers/Autoselect/`).  The element is inert until
  # the initializer picks it up on `turbolinks:load`.
  #
  # @param url [String]
  #   the autoselect resource, e.g. `/taxon_names/autoselect`
  # @param param [String, Symbol]
  #   the key read from the selected item's `response_values`, e.g. `:taxon_name_id`
  # @param object [String, Symbol, nil]
  #   the Rails form object name, e.g. `:otu`.  When nil the hidden input is named
  #   after `method` alone.
  # @param method [String, Symbol]
  #   the attribute written by the hidden input, e.g. `:taxon_name_id`
  # @param tag_id [String, nil]
  #   a globally unique id for the instance; it is the DOM id and the key user
  #   preferences are stored under.  A UUID is generated client-side when absent.
  # @param current [ApplicationRecord, nil]
  #   the presently assigned record, if any
  # @param current_label [String, nil]
  #   HTML label for `current`; defaults to the model's `<model>_autoselect_tag`
  # @param new_record_component [String, nil]
  #   key of the component opened by `!n`, e.g. 'TaxonNameNewModal'
  # @param preferences_options_component [String, nil]
  #   key of the component rendered inside the `!p` modal, e.g. 'ColDatasetPicker'
  def autoselect_field(
    url:,
    param:,
    method:,
    object: nil,
    tag_id: nil,
    current: nil,
    current_label: nil,
    placeholder: nil,
    disabled: false,
    level_delay: nil,
    new_record_component: nil,
    preferences_options_component: nil
  )
    content_tag(:div, '', data: {
      'autoselect' => true,
      'autoselect-url' => url,
      'autoselect-param' => param,
      'autoselect-field-object' => object,
      'autoselect-field-property' => method,
      'autoselect-id' => tag_id,
      'autoselect-placeholder' => placeholder,
      'autoselect-disabled' => disabled,
      'autoselect-level-delay' => level_delay,
      'autoselect-current-value' => current&.id,
      'autoselect-current-label' => current_label || autoselect_label_for(current),
      'autoselect-new-record-component' => new_record_component,
      'autoselect-preferences-options-component' => preferences_options_component
    })
  end

  # @return [String, nil]
  #   the HTML label a model renders in the autoselect dropdown
  def autoselect_label_for(record)
    return nil if record.nil?

    tag_method = "#{record.class.base_class.name.underscore}_autoselect_tag"

    respond_to?(tag_method) ? send(tag_method, record) : label_for(record)
  end
end
