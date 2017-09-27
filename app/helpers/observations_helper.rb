module ObservationsHelper

  def observation_tag(observation)
    return nil if observation.nil?
    "#{observation.descriptor.name}: #{observation.id}"
  end


end
