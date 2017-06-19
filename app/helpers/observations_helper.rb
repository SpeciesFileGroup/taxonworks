module ObservationsHelper

  def observation_tag(observation)
    return nil if observation.nil?
    "observation #{observation.id}"
  end


end
