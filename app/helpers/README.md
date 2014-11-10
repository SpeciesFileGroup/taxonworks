


Helper Descriptions
===================

See individual headers at https://github.com/SpeciesFileGroup/taxonworks/tree/master/app/helpers

Code Organization
=================

```Ruby
class <Model>Helper 

  # All _tag methods are additionally aliased to an object_ version, for example:
  #   <%= taxon_name_tag(@taxon_name) -%>  
  # is the same as 
  #   <%= object_tag(@taxon_name) -%>
  # and
  #    object_link(@taxon_name) 
  # is the same as 
  #    taxon_name_link(@taxon_name)
  #
  # Since these object_ methods provide another level of indirection, they are primarily used when the class 
  # of the object is not know, such as when one wishes to display a list of tags of differing classes 
  # of objects. Tag.tag_object is a good example, since this entry can refer to almost any kind of object.
  
  #
  # Exemplar data model helper methods 
  #    

  #  Return a single line, ideally wrapped in a content_tag(:span, ... ) naming the instance.
  def <model_name>_tag(model)
    return nil if model.nil
    # return some model.attribute of interpolated string of model attributes
  end

  #  Return a single line, ideally wrapped in a content_tag(:span, ... ) briefly naming the instance. 
  def <model_name>_short_tag(model)
  end

  #  Return one or more line, ideally wrapped in a content_tag(:div, ... ) detailing the instance.
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

Directory Organization
======================
* All rails model related and the standard application helpers are at /.  
* Workbench related helpers (general functionality, including styling, layout etc.) are at /workbench.
* Helpers related to vendor plugins are in /plugins (e.g. Papertrail)

