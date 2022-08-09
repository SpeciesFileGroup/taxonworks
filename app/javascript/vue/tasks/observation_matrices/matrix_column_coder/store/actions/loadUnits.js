import { Descriptor } from 'routes/endpoints'

export default ({ state }) =>
  Descriptor.units()
    .then(({ body }) => {
      state.units = body
    })
