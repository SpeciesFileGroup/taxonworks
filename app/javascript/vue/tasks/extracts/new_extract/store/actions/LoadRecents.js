import { MutationNames } from '../mutations/mutations'
import { Extract } from '@/routes/endpoints'

export default ({ commit }) => {
  Extract.where({
    recent: true,
    per: 12,
    extend: ['protocol', 'identifiers', 'otus', 'origin_types', 'origins']
  }).then(({ body }) => {
    commit(MutationNames.SetRecents, body)
  })
}
