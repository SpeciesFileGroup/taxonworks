module FormHelper
  # For use with an AJAX filled drop-down list.
  # Selects options from field
  # Call like " fill_in 'Name', with: 'Fooidae' "
  def fill_autocomplete(field, options = {})
    fill_in field, with: options[:with]

    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}

    expect(page).to have_selector('ul.ui-autocomplete li.ui-menu-item a')
    #sleep 2  # here only so a human eye can see what is happening - remove in final test
    page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
  end

end


