

Code Organization
=================
In progres...


  ```
  class FooHelper 

    # all of the model_ tags are additionally aliased to object_method_tag like:
    #  <%=  object_tag(@taxon_name) -%>

    # Tentative universal helper methods.

    # _tag methods are typically the #name of the instance
    #  ? perhaps name as model_name_tag(model)
    
    #
    #  Return a single line, content_tag(:span, ... ) naming the instance.
    def model_tag(model)
    end

    #  Return a single line, content_tag(:span, ... ) briefly naming the instance.
    def model_short_tag(model)
    end
  
    #  Return on or more line, content_tag(:div, ... ) detailing the instance.
    def model_detailed_tag(model)
    end

    # Return a link_to(model_path) using model_tag
    def model_link(model)
    end

    # Return a link_to(model_path) using model_short_tag
    def model_short_link(model)
    end

    # Return a content_tag(:li, model_tag(model))
    def model_select_item(model)
    end
    
  end

  ```
