import {
  AssertedDistribution,
  BiologicalAssociation,
  Citation,
  TaxonName
} from '@/routes/endpoints'
import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  TAXON_NAME
} from '@/constants/index.js'
import extend from '../../const/extendRequest.js'

const LIST_EXTENDERS = {
  [TAXON_NAME]: loadTaxonNamesIntoList,
  [ASSERTED_DISTRIBUTION]: loadAssertedDistributionsIntoList,
  [BIOLOGICAL_ASSOCIATION]: loadBiologicalAssociationsIntoList
}

export default async ({ state }, payload) => {
  const { sourceId, type, page, per } = payload

  const citationResponse = await Citation.where({
    citation_object_type: type,
    source_id: sourceId,
    extend,
    page,
    per
  })

  state.citations[type] = await extendCitationList(type, citationResponse.body)

  return citationResponse
}

async function extendCitationList(type, list) {
  const extendList = LIST_EXTENDERS[type]

  return extendList && list.length ? extendList(list) : list
}

async function loadTaxonNamesIntoList(list) {
  const taxonIds = list.map((item) => item.citation_object_id)
  let taxons = []

  if (taxonIds.length) {
    taxons = (
      await TaxonName.all(
        {
          taxon_name_id: taxonIds
        },
        { useFilter: true }
      )
    ).body
  }

  return list.map((item) => ({
    ...item,
    citation_object:
      taxons.find((taxon) => taxon.id === item.citation_object_id) ||
      item.citation_object
  }))
}

async function loadAssertedDistributionsIntoList(list) {
  const { body: assertedDistributions } = await AssertedDistribution.all(
    {
      asserted_distribution_id: list.map((item) => item.citation_object_id),
      extend: ['asserted_distribution_object']
    },
    { useFilter: true }
  )

  return list.map((item) => {
    const assertedDistribution = assertedDistributions.find(
      ({ id }) => id === item.citation_object_id
    )

    return {
      ...item,
      relatedObjects: makeRelatedObjects([
        assertedDistribution?.asserted_distribution_object
      ])
    }
  })
}

async function loadBiologicalAssociationsIntoList(list) {
  const { body: biologicalAssociations } = await BiologicalAssociation.all(
    {
      biological_association_id: list.map((item) => item.citation_object_id),
      extend: ['subject', 'object', 'biological_relationship']
    },
    { useFilter: true }
  )

  return list.map((item) => {
    const biologicalAssociation = biologicalAssociations.find(
      ({ id }) => id === item.citation_object_id
    )

    return {
      ...item,
      relationshipLabel:
        biologicalAssociation?.biological_relationship?.object_label,
      relatedObjects: makeRelatedObjects([
        biologicalAssociation?.subject,
        biologicalAssociation?.object
      ])
    }
  })
}

function makeRelatedObjects(objects) {
  return objects
    .filter(Boolean)
    .map(({ id, base_class, object_tag, object_url }) => ({
      id,
      base_class,
      object_tag,
      object_url
    }))
}
