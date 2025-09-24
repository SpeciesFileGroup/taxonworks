<template>
  <table>
    <thead>
      <tr>
        <th>Object</th>
        <th>Object type</th>
        <th>Shape</th>
        <th>Citation</th>
        <th>Trash</th>
        <th>Radial annotator</th>
        <th>Source/Object clone</th>
        <th>Source/Geo clone</th>
        <th>Object/Geo load</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.assertedDistributions"
        :key="item.id"
      >
        <td>
          <a
            v-if="browseObjectLink(item)"
            :href="browseObjectLink(item)"
            v-html="item.asserted_distribution_object.object_tag"
          />
          <span v-else>
            {{ item.asserted_distribution_object_type }}
          </span>
        </td>
        <td>
          {{ item.asserted_distribution_object_type }}
        </td>
        <td
          v-html="
            shapeLink(
              item.asserted_distribution_shape,
              item.asserted_distribution_shape_type
            )
          "
        />
        <td v-if="item.citations.length > 1">
          <CitationCount
            :citations="item.citations"
            @delete="(c) => store.removeAssertedDistributionCitation(c)"
          />
        </td>
        <td v-else>
          <div class="middle">
            <a
              class="margin-small-right"
              target="blank"
              :href="nomenclatureBySourceRoute(item.citations[0].source_id)"
              v-html="item.citations[0].citation_source_body"
            />
            <SoftValidation :global-id="item.global_id" />
          </div>
        </td>
        <td>
          <VBtn
            color="destroy"
            circle
            @click="removeItem(item)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </td>
        <td>
          <RadialAnnotator
            type="annotations"
            :global-id="item.global_id"
          />
        </td>
        <td>
          <VBtn
            color="primary"
            @click="() => setSourceObject(item)"
          >
            Clone
          </VBtn>
        </td>
        <td>
          <VBtn
            color="primary"
            @click="() => setSourceGeo(item)"
          >
            Clone
          </VBtn>
        </td>
        <td>
          <VBtn
            color="primary"
            @click="() => setGeoObject(item)"
          >
            Load
          </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator'
import CitationCount from './citationsCount'
import SoftValidation from '@/components/soft_validations/objectValidation.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/store'
import { Source } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import { toSnakeCase } from '@/helpers'

const store = useStore()

function nomenclatureBySourceRoute(id) {
  return `${RouteNames.NomenclatureBySource}?source_id=${id}`
}

function removeItem(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    store.removeAssertedDistribution(item)
  }
}

function browseObjectLink(item) {
  const model = item.asserted_distribution_object_type
  const browseTask = `Browse${model}`
  const browseLink = RouteNames[browseTask]
  if (browseLink) {
    return `${browseLink}?${ID_PARAM_FOR[model]}=${item.asserted_distribution_object_id}`
  } else {
    return `/${toSnakeCase(model)}s/${item.asserted_distribution_object_id}`
  }
}

function setSourceObject(item) {
  store.reset()
  setCitation(item.citations[0])
  store.object = {
    objectType: item.asserted_distribution_object_type,
    ...item.asserted_distribution_object
  }
}

function setSourceGeo(item) {
  store.reset()
  setCitation(item.citations[0])
  store.shape = {
    shapeType: item.asserted_distribution_shape_type,
    ...item.asserted_distribution_shape
  }
  store.isAbsent = item.is_absent
}

function setGeoObject(item) {
  store.reset()
  store.autosave = false
  store.assertedDistribution.id = item.id
  store.shape = {
    shapeType: item.asserted_distribution_shape_type,
    ...item.asserted_distribution_shape
  }
  store.object = {
    objectType: item.asserted_distribution_object_type,
    ...item.asserted_distribution_object
  }
  store.isAbsent = item.is_absent
}

function setCitation(citation) {
  Source.find(citation.source_id).then(({ body }) => {
    store.citation = {
      id: undefined,
      source: body,
      source_id: citation.source_id,
      is_original: citation.is_original,
      pages: citation.pages
    }
  })
}

function shapeLink(shape, type) {
  if (type == 'GeographicArea') {
    return `<a href="/geographic_areas/${shape.id}">${shape.name}</a>`
  } else {
    return `<a href="/gazetteers/${shape.id}">${shape.name}</a>`
  }
}
</script>
<style scoped>
table,
td,
tr {
  position: relative !important;
}
</style>
