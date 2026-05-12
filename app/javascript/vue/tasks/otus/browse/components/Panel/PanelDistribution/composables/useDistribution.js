import { Otu, CachedMap } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import {
  MAP_SHAPE_AGGREGATE,
  MAP_SHAPE_ASSERTED_DISTRIBUTION_ABSENT,
  TAXON_RANK_SPECIES_GROUP,
  TAXON_RANK_SPECIES_AND_INFRASPECIES_GROUP
} from '@/constants'
import { MAP_LEGEND } from '../constants/mapLegend.js'
import {
  removeDuplicateShapes,
  setPopupAndIconToFeatures,
  addAggregateDataToFeature
} from '../utils/index.js'

function sortFeaturesByType(arr, reference) {
  const referenceMap = new Map()

  reference.forEach((item, index) => {
    referenceMap.set(item, index)
  })

  return arr.toSorted((a, b) => {
    const indexA = referenceMap.has(a.properties.base.type)
      ? referenceMap.get(a.properties.base.type)
      : Infinity
    const indexB = referenceMap.has(b.properties.base.type)
      ? referenceMap.get(b.properties.base.type)
      : Infinity
    return indexA - indexB
  })
}

function isRankInSpeciesGroups(rank) {
  const rankGroup = rank.split('::').at(2)

  return [
    TAXON_RANK_SPECIES_GROUP,
    TAXON_RANK_SPECIES_AND_INFRASPECIES_GROUP
  ].includes(rankGroup)
}

async function loadAbsentFeatures(otuId) {
  try {
    const { body } = await Otu.geoJsonDistributionAbsent(otuId)
    const features = (body.features || []).map((feature) => ({
      ...feature,
      properties: {
        ...feature.properties,
        is_absent: true,
        base: [feature.properties.base],
        target: [feature.properties.target]
      }
    }))

    return setPopupAndIconToFeatures(features)
  } catch {
    return []
  }
}

async function loadAggregateMap(otuId) {
  try {
    const { body } = await Otu.geoJsonDistribution(otuId)
    const { features, shapeTypes } = removeDuplicateShapes(
      sortFeaturesByType(body.features, Object.keys(MAP_LEGEND))
    )

    return {
      shapeTypes,
      features: setPopupAndIconToFeatures(features)
    }
  } catch {}
}

async function loadGeoJSONDistribution(otuId) {
  try {
    const { body } = await Otu.distribution(otuId)
    const { body: cached } = await CachedMap.find(body.cached_map.id)
    const geojson = JSON.parse(body.cached_map.geo_json)
    const feature = addAggregateDataToFeature(geojson)

    return {
      shapeTypes: [MAP_SHAPE_AGGREGATE],
      features: setPopupAndIconToFeatures([feature]),
      cachedMap: cached
    }
  } catch {}
}

export default () => {
  const shapeTypes = ref([])
  const geojson = ref([])
  const cachedMap = ref()
  const isLoading = ref(false)
  const isAggregateMap = computed(() =>
    shapeTypes.value.includes(MAP_SHAPE_AGGREGATE)
  )

  const reset = () => {
    shapeTypes.value = []
    geojson.value = []
    cachedMap.value = undefined
  }

  const loadMapData = async (otuId, rank) => {
    const isSpeciesGroup = rank && isRankInSpeciesGroups(rank)

    isLoading.value = true

    try {
      const [data, absentFeatures] = await Promise.all([
        isSpeciesGroup
          ? loadAggregateMap(otuId)
          : loadGeoJSONDistribution(otuId),
        loadAbsentFeatures(otuId)
      ])

      const baseShapeTypes = data?.shapeTypes ?? []
      const baseFeatures = data?.features ?? []

      shapeTypes.value = absentFeatures.length
        ? [MAP_SHAPE_ASSERTED_DISTRIBUTION_ABSENT, ...baseShapeTypes]
        : baseShapeTypes
      geojson.value = [...baseFeatures, ...absentFeatures]
      cachedMap.value = data?.cachedMap
    } catch {
    } finally {
      isLoading.value = false
    }
  }

  return {
    shapeTypes,
    geojson,
    cachedMap,
    isLoading,
    isAggregateMap,
    loadMapData,
    reset
  }
}
