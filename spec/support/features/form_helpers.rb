module FormHelper
  # For use with an AJAX filled drop-down list.
  # Selects options from field
  # Call like " fill_in 'Name', with: 'Fooidae' "
  def fill_autocomplete(field, options = {})
    fill_in field, with: options[:with]

    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    css_selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
    xpath_selector = %Q{//ul[contains(concat(' ', normalize-space(@class), ' '), ' ui-autocomplete ')]} + 
                     %Q{//li[contains(concat(' ', normalize-space(@class), ' '), ' ui-menu-item ')]//a[contains(., "#{options[:select]}")]}
    expect(page).to have_xpath(xpath_selector)
    #sleep 2  # here only so a human eye can see what is happening - remove in final test
    page.execute_script %Q{ $('#{css_selector}').first().trigger('mouseenter').click() }
  end

end


