import { CollectionObject } from '@/routes/endpoints'
import { getPagination } from '@/helpers'

export async function getTotalCOByCEId(ceId) {
  const response = await CollectionObject.where({
    collecting_event_id: [ceId],
    per: 1
  })
  const pagination = getPagination(response)

  return pagination.total
}
