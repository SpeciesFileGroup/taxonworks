import { ref } from 'vue'
import {
  AnatomicalPart,
  Depiction,
  TaxonDetermination
} from '@/routes/endpoints'
import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
} from '@/constants'
import {
  DETERMINABLE_TYPES,
  classifyApplyOtu,
  objectKey,
  topOriginOfGraph
} from '../adapters/applyOtu'
import useStore, { runAll } from '../store/store'

const IDS_PER_REQUEST = 50
const MAX_DETERMINATIONS_PER_REQUEST = 1000

const BATCH_PARAM = {
  [COLLECTION_OBJECT]: 'collection_object_id',
  [FIELD_OCCURRENCE]: 'field_occurrence_id'
}

function chunk(list, size) {
  const chunks = []

  for (let i = 0; i < list.length; i += size) {
    chunks.push(list.slice(i, i + size))
  }

  return chunks
}

async function loadAnatomicalPartOrigins(ids) {
  const origins = new Map()

  await runAll([...new Set(ids)], async (id) => {
    const { body } = await AnatomicalPart.graph({ id, type: ANATOMICAL_PART })
    const origin = topOriginOfGraph(body)

    if (origin) origins.set(id, { type: origin.object_type, id: origin.id })
  })

  return origins
}

async function loadCurrentOtuIds(objects) {
  const currentOtuIds = new Map()

  for (const type of DETERMINABLE_TYPES) {
    const ids = [
      ...new Set(objects.filter((o) => o.type === type).map((o) => o.id))
    ]

    await runAll(chunk(ids, IDS_PER_REQUEST), async (idChunk) => {
      const { body } = await TaxonDetermination.where({
        taxon_determination_object_id: idChunk,
        taxon_determination_object_type: type,
        per: MAX_DETERMINATIONS_PER_REQUEST
      })

      body
        .filter((d) => d.position === 1)
        .forEach((d) => {
          currentOtuIds.set(
            objectKey(type, d.taxon_determination_object_id),
            d.otu_id
          )
        })
    })
  }

  return currentOtuIds
}

export function useApplyOtu() {
  const store = useStore()
  const plan = ref(null)
  const isLoading = ref(false)

  async function preview(items, otuId) {
    isLoading.value = true
    plan.value = null

    try {
      const depictionsByImage = await store.loadImageDepictions(
        items.map((it) => it.meta.objectId)
      )
      const freshItems = items.map((it) => ({
        id: it.id,
        meta: {
          ...it.meta,
          depictions: depictionsByImage.get(it.meta.objectId) || []
        }
      }))
      const depictions = freshItems.flatMap((it) => it.meta.depictions)

      const anatomicalPartOrigins = await loadAnatomicalPartOrigins(
        depictions
          .filter((d) => d.depiction_object_type === ANATOMICAL_PART)
          .map((d) => d.depiction_object_id)
      )

      const currentOtuIds = await loadCurrentOtuIds([
        ...depictions.map((d) => ({
          type: d.depiction_object_type,
          id: d.depiction_object_id
        })),
        ...anatomicalPartOrigins.values()
      ])

      plan.value = classifyApplyOtu({
        items: freshItems,
        otuId,
        currentOtuIds,
        anatomicalPartOrigins
      })
    } finally {
      isLoading.value = false
    }
  }

  async function apply(otuId) {
    const { moves, creates, determinations } = plan.value
    const result = { applied: 0, failed: 0 }

    async function track(request) {
      try {
        await request()
        result.applied++
      } catch {
        result.failed++
      }
    }

    isLoading.value = true

    try {
      for (const type of DETERMINABLE_TYPES) {
        const ids = determinations
          .filter((d) => d.objectType === type)
          .map((d) => d.objectId)

        if (!ids.length) continue

        try {
          const { body } = await TaxonDetermination.createBatch({
            [BATCH_PARAM[type]]: ids,
            taxon_determination: { otu_id: otuId }
          })

          result.applied += body.total_created
          result.failed += body.failed.length
        } catch {
          result.failed += ids.length
        }
      }

      await runAll(moves, ({ depiction }) =>
        track(() =>
          Depiction.update(depiction.id, {
            depiction: {
              depiction_object_id: otuId,
              depiction_object_type: OTU
            }
          })
        )
      )

      await runAll(creates, ({ imageId }) =>
        track(() =>
          Depiction.create({
            depiction: {
              image_id: imageId,
              depiction_object_id: otuId,
              depiction_object_type: OTU
            }
          })
        )
      )
    } finally {
      isLoading.value = false
    }

    return result
  }

  return {
    plan,
    isLoading,
    preview,
    apply
  }
}
