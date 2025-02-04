module ConveyancesHelper

  def conveyance_tag(conveyance)
    return nil if conveyance.nil?
    [ sound_tag(conveyance.sound), 'on', object_tag(conveyance.conveyance_object)  ].compact.join('&nbsp;')
  end

  def label_for_conveyance(conveyance)
    return nil if conveyance.nil?
    [ label_for_sound(conveyance.sound), 'on', label_for(conveyance.conveyance_object)  ].compact.join('&nbsp;')
  end

end
