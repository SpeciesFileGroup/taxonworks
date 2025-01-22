import baseCRUD from './base'

const permitParams = {
  sound: {
    name: Number,
    sound_file: String
  }
}

export const Sound = {
  ...baseCRUD('sounds', permitParams)
}
