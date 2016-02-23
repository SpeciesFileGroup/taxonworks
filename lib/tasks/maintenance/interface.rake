namespace :tw do
  namespace :maintenance do
    namespace :interface do
      desc 'reset user tab preferences'
      task  :reset_hub_tabs =>  [:environment] do |t|
        ActiveRecord::Base.transaction do
          User.update_all(hub_tab_order: DEFAULT_HUB_TAB_ORDER)
          puts "User hub tab order reset.".yellow.bold
        end
      end
    end
  end
end


