module SearchHelper

  def search_form_for_model(data_model) 
    search_partial = "#{data_model.name.tableize}_search_form"
    if self.respond_to?(search_partial)
      self.send(search_partial) 
    else
      content_tag(:em, "Search form not yet available.")
    end
  end 

end
