import baseCRUD, { annotations } from './base'

const controller = 'character_states'
const permitParams = {
  character_state: {
    name: String,
    key_name: String,
    description_name: String,
    label: String,
    descriptor_id: Number,
    position: Number
  }
}

export const CharacterState = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller)
}
