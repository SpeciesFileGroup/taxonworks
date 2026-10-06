require 'rails_helper'

describe 'Session keepalive', type: :feature do

  # The keepalive and the expired-session modal are mounted by
  # app/javascript/vue/initializers/SessionKeepalive/main.js onto this element.
  # Losing it from the layout would silently disable both.
  context 'when a project is selected' do
    before { sign_in_user_and_select_project }

    it 'renders the mount point for the expired session modal' do
      visit root_path

      expect(page).to have_css('#vue-session-expired-modal', visible: :all)
    end
  end

  context 'when signed out' do
    it 'does not render the mount point' do
      visit signin_path

      expect(page).not_to have_css('#vue-session-expired-modal', visible: :all)
    end
  end

  # The session only carries the project selection: identity lives in the
  # permanent `remember_token` cookie. With no project selected there is
  # nothing in the session left to lose, so running the keepalive here would
  # only mean telling a user who simply has not picked a project yet that their
  # session expired -- once every PING_INTERVAL, for as long as they sit on the
  # dashboard.
  context 'when signed in but no project is selected' do
    before { sign_in_user }

    it 'does not render the mount point' do
      visit root_path

      expect(page).not_to have_css('#vue-session-expired-modal', visible: :all)
    end
  end

  context 'when the credentials are gone', js: true do
    before { sign_in_user_and_select_project }

    # Standing in for a machine suspended past the expiry window. Nothing is
    # clicked and the tab never loses focus or visibility, so the polling timer
    # in keepalive.js is the only thing that can notice.
    #
    # It deletes `remember_token` rather than `_TaxonWorks_session` on purpose:
    # geckodriver drops an httponly cookie from the WebDriver view but the page
    # still sends it on its own XHRs, so deleting the session cookie here proves
    # nothing. Either way the server is what decides, and this drives the same
    # path: timer fires -> ping -> the answer says the session is unusable ->
    # modal.
    it 'tells the user their session expired' do
      visit root_path

      page.driver.browser.manage.delete_cookie('remember_token')
      age_last_alive_at(PAST_EXPIRY)

      expect(page).to have_content('Session expired')
      expect(page).to have_button('Reload page')
    end

    # Turbolinks swaps the body instead of reloading, so the initializer tears
    # the keepalive down on `turbolinks:before-render` and starts it again on
    # the next `turbolinks:load`. Getting either half of that wrong leaves a
    # navigated tab with no timer, which is exactly the tab this feature is for.
    it 'still notices after a Turbolinks navigation' do
      visit root_path

      navigated_at = page.evaluate_script('Date.now()')
      page.execute_script("Turbolinks.visit('/hub')")

      expect(page).to have_current_path('/hub', ignore_query: true)

      wait_for_keepalive_restart(after: navigated_at)

      page.driver.browser.manage.delete_cookie('remember_token')
      age_last_alive_at(PAST_EXPIRY)

      expect(page).to have_content('Session expired')
    end
  end

  # The failure paths above are only half the promise. This is the other half:
  # a tab nobody touches renews its own session and the user never finds out
  # anything happened.
  context 'while the session is healthy', js: true do
    before { sign_in_user_and_select_project }

    it 'renews the session without bothering the user' do
      visit root_path

      before_stamp = stored_last_alive_at
      age_last_alive_at(PAST_PING_INTERVAL)

      wait_for_ping_to('session_status')

      expect(stored_last_alive_at).to be > before_stamp
      expect(page).not_to have_content('Session expired')
    end
  end

  # Ageing the shared timestamp is how these specs reach a state that would
  # otherwise take ten minutes (or a day) of real waiting: every decision the
  # keepalive makes is a wall clock subtraction against it.
  PAST_PING_INTERVAL = 61 * 60 * 1000
  PAST_EXPIRY = 25 * 60 * 60 * 1000

  def stored_last_alive_at
    page.evaluate_script(
      "Number(window.localStorage.getItem('tw:session:lastAliveAt'))"
    )
  end

  def age_last_alive_at(milliseconds)
    page.execute_script(
      "window.localStorage.setItem('tw:session:lastAliveAt', String(Date.now() - #{milliseconds}))"
    )
  end

  # Restarting stamps the timestamp fresh, so a stamp newer than the moment the
  # navigation began is the signal that the keepalive came back up. Waiting for
  # it is also what keeps the ageing that follows from being overwritten a
  # moment later.
  def wait_for_keepalive_restart(after:)
    deadline = Time.now + Capybara.default_max_wait_time

    until stored_last_alive_at > after
      raise 'the keepalive never restarted after the Turbolinks navigation' if Time.now > deadline

      sleep 0.1
    end
  end

  # Capybara can only wait on the DOM, and a heartbeat leaves no mark there, so
  # the browser's own resource timing is what says whether it went out.
  def wait_for_ping_to(path)
    deadline = Time.now + Capybara.default_max_wait_time

    until page.evaluate_script(
      "performance.getEntriesByType('resource').filter((e) => e.name.includes('#{path}')).length"
    ).to_i.positive?
      raise "the keepalive never requested #{path}" if Time.now > deadline

      sleep 0.1
    end
  end
end
