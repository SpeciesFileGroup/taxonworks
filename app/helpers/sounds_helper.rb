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
    begin
      t = File.open(
        ActiveStorage::Blob.service.path_for(sound.sound_file.attachment.key)
      )
    rescue Errno::ENOENT
      if Rails.env.production?
        raise TaxonWorks::Error,
          "Sound '#{sound.id}' missing its sound file at '#{sound.sound_file}'"
      else
        return { error: 'Missing sound file' }
      end
    end
    w = ::WahWah.open(t)
    # This brakes on binary strings
    #m = w.as_json.compact.delete_if{|k,v| v.blank?}
    #m.delete 'file_io'
    #m

    # Metadata. Add more as needed.
    {
      duration: w.duration,
      sample_rate: w.sample_rate
    }
   end

end
