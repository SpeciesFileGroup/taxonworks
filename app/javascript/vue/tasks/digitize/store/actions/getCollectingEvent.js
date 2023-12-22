import { MutationNames } from '../mutations/mutations'
import { CollectingEvent, CollectionObject } from '@/routes/endpoints'
import {
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_TRIP_CODE
} from '@/constants/index.js'
import makeIdentifier from '@/factory/CollectingEvent'
import { getPagination } from '@/helpers'

export default async ({ commit, state }, id) =>
  CollectingEvent.find(id, { extend: ['roles'] }).then(async ({ body }) => {
    commit(MutationNames.SetCollectingEvent, body)
    commit(
      MutationNames.SetCollectingEventIdentifier,
      body.identifiers[0] ||
        makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT)
    )

    const response = await CollectionObject.where({
      collecting_event_id: [body.id],
      per: 1
    })

    state.ceTotalUsed = getPagination(response).total
  })
