include Rainbow

namespace :tw do
  namespace :maintenance do
    namespace :interface do
      desc 'reset user tab preferences'
      task  reset_hub_tabs: [:environment] do |t|
        ApplicationRecord.transaction do
          User.update_all(hub_tab_order: DEFAULT_HUB_TAB_ORDER)
          print Rainbow('User hub tab order reset.').yellow.bold
          print "\n"
        end
      end
    end
  end
end
