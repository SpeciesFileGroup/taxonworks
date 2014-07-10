

Code Organization
=================
In progres...


  ```
  class FooHelper 

    # All _tag methods are additionally aliased to an object_ version, for example:
    #   <%= taxon_name_tag(@taxon_name) -%>  
    # is the same as 
    #   <%= object_tag(@taxon_name) -%>
    # and
    #    object_link(@taxon_name) 
    # is the same as 
    #    taxon_name_link(@taxon_name)
    #
    # Tentative data model helper methods.
    #    
 
    #  Return a single line, content_tag(:span, ... ) naming the instance.
    def <model_name>_tag(model)
    end

    #  Return a single line, content_tag(:span, ... ) briefly naming the instance.
    def <model_name>_short_tag(model)
    end
  
    #  Return on or more line, content_tag(:div, ... ) detailing the instance.
    def <model_name>_detailed_tag(model)
    end

    # Return a link_to(model_path) using model_tag
    def <model_name>_link(model)
    end

    # Return a link_to(model_path) using model_short_tag
    def model_short_link(model)
    end

    # Return a content_tag(:li, model_tag(model))
    def model_select_item(model)
    end
    
  end
  ```
