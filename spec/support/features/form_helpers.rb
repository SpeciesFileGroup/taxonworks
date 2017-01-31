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
      wait_for_ajax

    # page.execute_script %Q{ $('##{field}').trigger('focus') }
    # page.execute_script %Q{ $('##{field}').trigger('keydown') }
      page_body = page.body
      sleep 7
      css_selector = %Q{li.ui-menu-item a[data-model-id="#{options[:select]}"]}
      expect(page).to have_css(css_selector)

      # TODO: remove redundant xpath test(?)
      #  xpath_selector = %Q{//ul[contains(concat(' ', normalize-space(@class), ' '), ' ui-autocomplete ')]} +
      #                  %Q{//li[contains(concat(' ', normalize-space(@class), ' '), ' ui-menu-item ')]//a[contains(., "#{options[:select]}")]}
      # expect(page).to have_path(xpath_selector)

      #sleep 2  # here only so a human eye can see what is happening - remove in final test

      page.execute_script(%Q{ $('#{css_selector}').trigger('mouseenter').click(); })
    end

    def fill_role_picker_autocomplete(field, options = {})
      raise "fill_role_picker_autocomplete requires with: 'search term' and an ID to select (e.g. select: 2)" if options[:with].nil? || options[:select].nil?

      fill_in field, with: options[:with]

    # page.execute_script %Q{ $('##{field}').trigger('focus') }
    # page.execute_script %Q{ $('##{field}').trigger('keydown') }

      css_selector = %Q{li.ui-menu-item a span[data-person-id="#{options[:select]}"]}
      expect(page).to have_css(css_selector)

      page.execute_script(%Q{ $('#{css_selector}').trigger('mouseenter').click(); })
    end

    def fill_otu_widget_autocomplete(field, options = {})
      raise "fill_otu_widget_autocomplete requires with: 'search term' and an ID to select (e.g. select: 2)" if options[:with].nil? || options[:select].nil?
      css_selector = %Q{li.ui-menu-item[id=ui-otu-id-#{options[:select]}]}
      fill_in field, with: options[:with]
      wait_for_ajax
      expect(page).to have_css(css_selector)
      page.execute_script(%Q{ $('#{css_selector}').trigger('mouseenter').click(); })
    end

    def fill_keyword_autocomplete(field, options = {})
      css_selector = %Q{li.ui-menu-item a span[data-tag-id="#{options[:select]}"]}
      fill_in field, with: options[:with]
      wait_for_ajax
      expect(page).to have_css(css_selector)
      page.execute_script(%Q{ $('#{css_selector}').trigger('mouseenter').click(); })
    end

  end
end

