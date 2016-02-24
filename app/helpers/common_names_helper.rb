module CommonNamesHelper


  def common_name_tag(common_name)
    return nil if common_name.nil?
    common_name.name
  end


end
