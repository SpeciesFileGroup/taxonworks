module CharacterStatesHelper

  def character_state_tag(character_state)
    return nil if character_state.nil?
    [character_state.label, ':', character_state.name].join(' ')
  end

end
