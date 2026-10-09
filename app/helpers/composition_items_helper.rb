module CompositionItemsHelper

  def composition_item_tag(composition_item)
    return nil if composition_item.nil?
    s = [composition_item.type.demodulize]
    if composition_item.text.present?
      s.push(ERB::Util.html_escape(composition_item.text))
    end
    if o = composition_item.composition_item_object
      s.push(ERB::Util.html_escape(label_for(o)))
    end
    s.join(' ')
  end

  def label_for_composition_item(composition_item)
    return nil if composition_item.nil?
    s = [composition_item.type.demodulize]
    s.push(composition_item.text) if composition_item.text.present?
    if o = composition_item.composition_item_object
      s.push(label_for(o))
    end
    s.join(' ')
  end

end
