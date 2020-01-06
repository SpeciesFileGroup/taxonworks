module Features
  module FormHelpers

    # a specific helper for the mx-autocomplete ajax-based input only!
    #
    # Selects options from field
    #    fill_in('Name', with: 'Fooidae', select: 2")
    # Where
    #   field - is the name attribute of the input
    #   :with - the text to enter
    #   :select - is the id of of the instance (!! warning, if search results return non-uniq ids pre list item this will fail!)
    #
    def fill_autocomplete(field, options = {})
      raise "fill_autocomplete requires with: 'search term' and an ID to select (e.g. select: 2)" if options[:with].nil? || options[:select].nil?
      fill_in field, with: options[:with]
      css_selector = %Q{li.ui-menu-item a[data-model-id="#{options[:select]}"]}
      find(css_selector).hover.click
    end

    def fill_role_picker_autocomplete(field, options = {})
      raise "fill_role_picker_autocomplete requires with: 'search term' and an ID to select (e.g. select: 2)" if options[:with].nil? || options[:select].nil?
      css_selector = %Q{li.ui-menu-item a span[data-person-id="#{options[:select]}"]}
      fill_in field, with: options[:with]
      find(css_selector).hover.click
    end

    def fill_otu_widget_autocomplete(field, options = {})
      raise "fill_otu_widget_autocomplete requires with: 'search term' and an ID to select (e.g. select: 2)" if options[:with].nil? || options[:select].nil?
      css_selector = %Q{li.ui-menu-item[id=ui-otu-id-#{options[:select]}]}
      fill_in field, with: options[:with]
      find(css_selector).hover.click
    end

    def fill_keyword_autocomplete(field, options = {})
      css_selector = %Q{li.ui-menu-item a span[data-tag-id="#{options[:select]}"]}
      fill_in field, with: options[:with]
      find(css_selector).hover.click
    end

    # @param [field] selector provided to fill_in
    # @param [with] text to fill in
    # @param [select_id] id of the object to select
    # @param [object_type] type of the object to select, object-case-id
    def fill_autocomplete_and_select(field, with: nil, select_id: nil, object_type: nil)
      raise(ArgumentError, 'missing arguments') if with.nil? || select_id.nil? || object_type.nil?
      css_selector = %Q{li.ui-menu-item a[data-#{object_type}-id="#{select_id}"]}
      fill_in field, with: with
      find(css_selector).hover.click
    end

    def fill_area_picker_autocomplete(field, options = {})
      css_selector = %Q{li.ui-menu-item a[data-geographic-area-id="#{options[:select]}"]}
      fill_in field, with: options[:with]
      find(css_selector).hover.click
    end

  end

end

