module CompositionItemsHelper

  def composition_item_tag(composition_item)
    return nil if composition_item.nil?
    s = [composition_item.type.demodulize]
    if o = composition_item.composition_item_object
      s.push(ERB::Util.html_escape(label_for(o)))
    end
    s.join(' ')
  end

  def label_for_composition_item(composition_item)
    return nil if composition_item.nil?
    s = [composition_item.type.demodulize]
    if o = composition_item.composition_item_object
      s.push(label_for(o))
    end
    s.join(' ')
  end

end
