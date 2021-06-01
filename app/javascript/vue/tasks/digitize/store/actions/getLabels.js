import { Label } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from '../actions/actions'

export default ({ dispatch, commit }, id) =>
  Label.where({
    label_object_id: id,
    label_object_type: 'CollectingEvent'
  }).then(response => {
    if (response.body.length) {
      commit(MutationNames.SetLabel, response.body[0])
    } else {
      dispatch(ActionNames.NewLabel)
    }
  })
