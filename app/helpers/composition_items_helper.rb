module CompositionItemsHelper

  def composition_item_tag(composition_item)
    return nil if composition_item.nil?
    s = [composition_item.type.demodulize]
    if composition_item.text.present?
      s.push(ERB::Util.html_escape(composition_item.text))
    end
    # Some objects have no label, e.g. Images
    if (o = composition_item.composition_item_object) &&
        (l = label_for(o)).present?
      s.push(ERB::Util.html_escape(l))
    end
    s.join(' ')
  end

  def label_for_composition_item(composition_item)
    return nil if composition_item.nil?
    s = [composition_item.type.demodulize]
    s.push(composition_item.text) if composition_item.text.present?
    if (o = composition_item.composition_item_object) &&
        (l = label_for(o)).present?
      s.push(l)
    end
    s.join(' ')
  end

end
