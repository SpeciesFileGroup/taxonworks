import { COLLECTING_EVENT_PROPERTIES } from 'shared/Filter/constants'

export const LAYOUTS = {
  All: {
    properties: {
      collecting_event: [...COLLECTING_EVENT_PROPERTIES, 'identifiers', 'roles']
    },
    includes: {
      data_attributes: true
    }
  },

  DataAttributes: {
    properties: {},
    includes: {
      data_attributes: true
    }
  }
}
