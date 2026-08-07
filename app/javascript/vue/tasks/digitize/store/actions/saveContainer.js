import { MutationNames } from '../mutations/mutations'
import { Container } from '@/routes/endpoints'
import { CONTAINER_VIRTUAL } from '@/constants/index.js'

export default async ({ commit }) => {
  const container = {
    type: CONTAINER_VIRTUAL
  }

  const request = Container.create({ container, extend: ['container_items'] })

  request
    .then((response) => {
      commit(MutationNames.SetContainer, response.body)
    })
    .catch(() => {})

  return request
}
