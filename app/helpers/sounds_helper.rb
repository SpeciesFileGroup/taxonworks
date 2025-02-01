module SoundsHelper

  def sound_tag(sound)
    return nil if sound.nil?
    [ sound.name,
      sound.sound_file.attachment.filename.to_s
    ].compact.join(': ')
  end

  def label_for_sound(sound)
    return nil if sound.nil?
    sound.name || "sound #{sound.id}"
  end

  def sounds_search_form
    render('/sounds/quick_search_form')
  end

  def sound_link(sound)
    return nil if sound.nil?
    link_to(sound_tag(sound), sound.metamorphosize).html_safe
  end

  def sound_metadata(sound)
    return {} if sound.nil?
    w = ::WahWah.open(sound.sound_file.download)
    return { foo: w.year } 
  end

end
