import { RemoveDocumentation } from '../../request/resources'
export default ({ state }, documentation) => {
  RemoveDocumentation(documentation.id).then(() => {
    const index = state.documentations.findIndex(item => item.id === documentation.id)

    state.documentations.splice(index, 1)
  })
}
