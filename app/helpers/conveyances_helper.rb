module ConveyancesHelper

  def conveyance_tag(conveyance)
    return nil if conveyance.nil?
    [ sound_tag(conveyance.sound), 'on', object_tag(conveyance.conveyance_object)  ].compact.join('&nbsp;').html_safe
  end

  def label_for_conveyance(conveyance)
    return nil if conveyance.nil?
    [ label_for_sound(conveyance.sound), 'on', label_for(conveyance.conveyance_object)  ].compact.join('&nbsp;')
  end

  def conveyances_list_tag(object)
    if object.conveyances.any?
      object.conveyances.collect{|c|
        content_tag(:div) do
          safe_join([
            audio_tag(c.sound.sound_file, controls: true), 
            content_tag(:div, conveyance_tag(c))
          ])
        end
      }.join.html_safe
    end
  end
end
