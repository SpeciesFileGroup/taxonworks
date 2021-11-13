
# Helpers

## Directory Organization
* All rails model related and the standard application helpers are at /.  
* Workbench related helpers (general functionality, including styling, layout etc.) are at /workbench.
* Helpers related to vendor plugins are in /plugins (e.g. Papertrail)
* All other helpers are nested in helpers/lib/

## Helper Descriptions

See individual headers at https://github.com/SpeciesFileGroup/taxonworks/tree/master/app/helpers

## Code Organization

TODO: Go over patterns, clean up where no longer pertinent.

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
  #  Often contains html.
  def <model_name>_tag(object)
    return nil if object.nil
    # return some object.attribute of interpolated string of object attributes
  end

  #  Return a single line, ideally wrapped in a content_tag(:span, ... ) briefly naming the instance. 
  #  May contain html.
  def <model_name>_short_tag(object)
  end

  #  Return one or more line, ideally wrapped in a content_tag(:div, ... ) detailing the instance.
  #  Rarely used at present.  Often contains html.
  def <model_name>_detailed_tag(object)
  end

  # Return a link_to(model_path) using model_tag
  def <model_name>_link(object)
  end

  # Return a link_to(model_path) using model_short_tag
  def <model_name>_short_link(object)
  end

  # Return a content_tag(:li, <model>_tag(object))
  def <model_name>_select_item(mobject)
  end

  # Return a label to be used in autocomplete dropdown lists
  # May (usually) contain HTML.
  # Note that HTML inputs do not support HTML, so you 
  # likely want to create label_for_<model> to go with this.
  # Typically used in ../views/../autocomplete.json
  def <model_name>_autocomplete_tag(object)
  end

  # Return a String
  #  An equivalent to object_tag, but never with HTML!
  #  Same as
  #     label_for(object)
  def label_for_<model>(object)
  end
  
end
```

