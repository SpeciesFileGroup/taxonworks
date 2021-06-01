import { Documentation } from 'routes/endpoints'

export default ({ state }, documentation) => {
  Documentation.destroy(documentation.id).then(() => {
    const index = state.documentations.findIndex(item => item.id === documentation.id)

    state.documentations.splice(index, 1)
  })
}
