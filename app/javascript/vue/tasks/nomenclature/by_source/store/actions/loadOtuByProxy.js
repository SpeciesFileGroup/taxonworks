import { chunkArray } from "helpers/arrays"
import { Otu } from "routes/endpoints"
import { MutationNames } from "../mutations/mutations"

const CHUNK_SIZE = 50

export default ({ commit }, { list, param }) => {
  const objectsId = list.map(item => item.citation_object_id)
  const idList = chunkArray(objectsId, CHUNK_SIZE)
  const requests = idList.map(ids => Otu.where({ [param]: ids }))

  Promise.all(requests).then(responses => {
    commit(MutationNames.SetOtuList, [].concat(...responses.map(({ body }) => body)))
  })
}
