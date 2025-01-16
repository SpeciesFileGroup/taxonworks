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

end
