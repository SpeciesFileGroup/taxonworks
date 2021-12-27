import { User } from 'routes/endpoints'

export default ({ state }, { key, value }) =>
  User.update(state.preferences.id, { user: { layout: { [key]: value } } }).then(response => {
    state.preferences.layout = response.body.preferences.layout
})
