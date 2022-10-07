import { SoftValidation } from 'routes/endpoints'

export default ({ state }, { globalId, objectType }) => {
  SoftValidation.find(globalId).then(({ body }) => {
    Object.assign(state.softValidations, {
      [objectType]: [{ list: [body], title: body.instance.klass }]
    })
  })
}
