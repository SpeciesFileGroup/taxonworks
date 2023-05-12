import { SoftValidation } from 'routes/endpoints'

export default ({ state }, globalId) => {
  SoftValidation.find(globalId).then(({ body }) => {
    if (body.soft_validations.length) {
      state.softValidations.push({
        list: [body],
        title: body.instance.klass
      })
    }
  })
}
