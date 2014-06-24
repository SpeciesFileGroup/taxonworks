module NavigationHelper

  def quick_bar
    render(partial: '/navigation/quick_bar') if is_data_controller?
  end

end
