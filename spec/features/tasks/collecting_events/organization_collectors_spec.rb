require 'rails_helper'

RSpec.describe 'Organization collector entry', type: :feature, js: true do
  before do
    sign_in_user_and_select_project
    @organization = Organization.create!(name: 'Museum expedition', creator: @user, updater: @user)
  end

  def choose_organization
    find('label', text: 'Organization', exact_text: true).click
    fill_in 'Search an organization', with: 'Museum'
    page.document.find('.vue-autocomplete-item', text: 'Museum expedition').click
    expect(page).to have_css('li.list-complete-item', text: 'Museum expedition')
  end

  it 'saves and reopens a mixed list, reorders and removes organization collectors' do
    person = Person.create!(last_name: 'Browserperson', creator: @user, updater: @user)
    visit new_collecting_event_task_path
    fill_in 'verbatim_label', with: 'Mixed collector browser test'
    within(find('fieldset', text: 'Collectors', match: :first)) do
      choose_organization
      find('label', text: 'People', exact_text: true).click
      fill_in 'Family name, given name', with: 'Browserperson'
      page.document.find('.vue-autocomplete-item', text: 'Browserperson').click
      expect(page).to have_css('li.list-complete-item', text: 'Browserperson')
    end
    click_button 'Save', exact: true
    expect(page).to have_content('Collecting event was successfully saved.')
    event = CollectingEvent.find_by!(verbatim_label: 'Mixed collector browser test')
    visit "#{new_collecting_event_task_path}?collecting_event_id=#{event.id}"
    within(find('fieldset', text: 'Collectors', match: :first)) do
      expect(page).to have_css('li.list-complete-item', text: 'Museum expedition')
      expect(page).to have_css('li.list-complete-item', text: 'Browserperson')
      source = find('li.list-complete-item', text: 'Browserperson')
      target = find('li.list-complete-item', text: 'Museum expedition')
      source.scroll_to(:center)
      # Exercise Sortable's DOM listeners without depending on Vue's development-only internals.
      page.evaluate_async_script(<<~JS, source, target)
        const [source, target, done] = arguments
        const sourceRect = source.getBoundingClientRect()
        const targetRect = target.getBoundingClientRect()
        const dataTransfer = new DataTransfer()
        const start = {
          bubbles: true, cancelable: true, button: 0,
          clientX: sourceRect.x + sourceRect.width / 2,
          clientY: sourceRect.y + sourceRect.height / 2
        }
        const destination = {
          ...start, dataTransfer,
          clientX: targetRect.x + targetRect.width / 2,
          clientY: targetRect.y + 1
        }
        source.dispatchEvent(new PointerEvent('pointerdown', { ...start, pointerType: 'mouse' }))
        source.dispatchEvent(new MouseEvent('mousedown', start))
        source.dispatchEvent(new DragEvent('dragstart', { ...start, dataTransfer }))
        // Sortable schedules its drag-start setup for the next event-loop turn.
        setTimeout(() => {
          target.dispatchEvent(new DragEvent('dragover', destination))
          target.dispatchEvent(new DragEvent('drop', destination))
          source.dispatchEvent(new DragEvent('dragend', { ...start, dataTransfer }))
          done()
        }, 0)
      JS
      expect(page).to have_css('li.list-complete-item:first-child', text: 'Browserperson')
    end
    click_button 'Save', exact: true
    expect(page).to have_content('Collecting event was successfully saved.')
    expect(event.reload.collector_roles.order(:position).map { |role| role.agent.name }).to eq([person.name, @organization.name])
    visit "#{new_collecting_event_task_path}?collecting_event_id=#{event.id}"
    within(find('fieldset', text: 'Collectors', match: :first)) do
      within(find('li.list-complete-item', text: 'Museum expedition')) { all('button').last.click }
    end
    click_button 'Save', exact: true
    expect(page).to have_content('Collecting event was successfully saved.')
    expect(event.reload.collectors_organization).to be_empty
  end
  it 'assigns organizations with the stepwise collector tool' do
    events = 3.times.map do |i|
      CollectingEvent.create!(verbatim_label: "Stepwise event #{i}", verbatim_collectors: 'Expedition team', project: @project, creator: @user, updater: @user)
    end
    visit stepwise_collectors_task_path
    range = find('input[type="range"]')
    range.send_keys(:home)
    page.execute_script("arguments[0].dispatchEvent(new MouseEvent('mouseup', { bubbles: true }))", range)
    click_button 'Pick', exact: true
    within(find('table', text: 'DwC')) { find('thead input[type="checkbox"]').check }
    within(find('fieldset', text: 'Collector', match: :first)) { choose_organization }
    click_button 'Set collectors'
    expect(page).to have_no_css('td', text: 'Stepwise event')
    expect(page).to have_content('Stepwise collectors')
    expect(events.flat_map { |event| event.reload.collectors_organization.to_a }).to eq([@organization] * 3)
  end

  it 'previews and applies organization collectors through the batch tool' do
    event = CollectingEvent.create!(verbatim_label: 'Batch organization test', project: @project, creator: @user, updater: @user)
    visit "#{filter_collecting_events_task_path}?collecting_event_id[]=#{event.id}"
    expect(page).to have_content('Batch organization test')
    find('tbody input[type="checkbox"]').check
    find('button[aria-label="Radial collecting event"]:not([disabled])', match: :first).click
    find('svg tspan', text: 'Collectors', exact_text: true).click
    within(find('fieldset', text: 'Collector', match: :first)) { choose_organization }
    click_button 'Preview', exact: true
    expect(page).to have_content('Preview response')
    expect(page).to have_css('td', text: 'Updated', exact_text: true)
    expect(event.reload.collector_roles).to be_empty
    click_button 'Finalize', exact: true
    fill_in 'Write CHANGE to continue', with: 'CHANGE'
    find('button.button-submit', text: 'Update', exact_text: true).click
    expect(page).to have_content('Updated')
    expect(event.reload.collectors_organization).to eq([@organization])
  end

end
