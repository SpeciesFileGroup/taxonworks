# Generic wrappers around AR instances, these should not include link generation, but may call out to other helpers that do generate links. 
# See /app/helpers/README.md for more.
#
module Workbench::DisplayHelper
  
  # General wrapper around individual <model_name>_tag methods
  #   object_tag(@otu) 
  def object_tag(object)
    return nil if object.nil?
    method = object_tag_method(object)

    # meh, exceptions  
    return send('taxon_works_content_tag', object).html_safe if method == 'content_tag' 
    return image_tag(object.image_file.url(:thumb)) if method == 'image_tag' 

    if self.respond_to?(method)
      html = send(method, object)
      html ? html.html_safe : nil
    else
      nil #  content_tag(:span,"#{object.class} has no helper method '#{method}'", class: :warning)
    end
  end

  def object_tag_method(object)
    return nil if object.nil?
    klass_name = object.class.name
    method = "#{klass_name.underscore.gsub('/', '_')}_tag"
    if ApplicationController.helpers.respond_to?(method)
      method
    else
      klass_name = metamorphosize_if(object).class.name
      "#{klass_name.underscore}_tag"
    end
  end

  # General wrapper around individual <model_name>_tag methods
  #   label_for(@otu) 
  def label_for(object)
    return nil if object.nil?
    method = label_for_method(object)

    if self.respond_to?(method)
      string = send(method, object)
      return string if string
    else
      nil 
    end
  end

  def label_for_method(object)
    return nil if object.nil?
    klass_name = object.class.name
    method = "label_for_#{klass_name.underscore.gsub('/', '_')}"
    if ApplicationController.helpers.respond_to?(method)
      method
    else
      klass_name = metamorphosize_if(object).class.name
      "label_for_#{klass_name.underscore}"
    end
  end

  def model_name_title
    controller_name.humanize
  end

  def kind(object)
    object.class.name.humanize
  end

  def object_attributes_partial_path(object)
    "/#{metamorphosize_if(object).class.base_class.name.tableize}/attributes"
  end

  def object_card_partial_path(object)
    '/' + object_class_name(object) + '/card'
  end

  def object_class_name(object)
    object.class.base_class.name.tableize.to_s
  end

  # @return [String, nil]
  #   use `mark` tags to highlight the position of the term in the text
  def regex_mark_tag(text, term)
    return text if term.nil?
    if t = text[/#{Regexp.escape(term)}/i]  # probably some look-ahead (behind) magic could be used here
      text.gsub(/#{Regexp.escape(term)}/i, "<mark>#{t}</mark>")
    else
      text
    end
  end

end
