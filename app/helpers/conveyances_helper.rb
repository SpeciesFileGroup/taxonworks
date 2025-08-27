module ConveyancesHelper
  include RecordNavigationHelper

  def conveyance_tag(conveyance)
    return nil if conveyance.nil?
    [ sound_tag(conveyance.sound), 'on', object_tag(conveyance.conveyance_object)  ].compact.join('&nbsp;').html_safe
  end

  def conveyance_autocomplete_tag(conveyance)
    conveyance_tag(conveyance)
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
            player_for_sound(c.sound),
            content_tag(:div, conveyance_tag(c))
          ])
        end
      }.join.html_safe
    end
  end

  def player_for_sound(sound)
    sound_path =
      ActiveStorage::Blob.service.path_for(sound.sound_file.attachment.key)
    if File.exist?(sound_path)
      audio_tag(sound.sound_file, controls: true)
    else
      if Rails.env.production?
        raise TaxonWorks::Error,
          "Sound #{sound.id} missing its sound file at '#{sound.sound_file}'"
      else
        content_tag(:div, style: 'color: red') do
          'Missing sound file'
        end
      end
    end
  end

  # @return !!Array!!
  def previous_records(conveyance)
    # !! Note we only return conveyances on Otus currently.
    c = ::Conveyance
      .joins("JOIN otus ON conveyances.conveyance_object_type = 'Otu' AND conveyances.conveyance_object_id = otus.id")
      .where(project_id: conveyance.project_id)
      .where('conveyances.id < ?', conveyance.id)
      .order(id: :desc)
      .first

    [c].compact
  end

  # @return !!Array!!
  def next_records(conveyance)
    # !! Note we only return conveyances on Otus currently.
    c = ::Conveyance
      .joins("JOIN otus ON conveyances.conveyance_object_type = 'Otu' AND conveyances.conveyance_object_id = otus.id")
      .where(project_id: conveyance.project_id)
      .where('conveyances.id > ?', conveyance.id)
      .order(:id)
      .first

    [c].compact
  end

end
