<template>
  <table>
    <thead>
      <tr>
        <th>Otu</th>
        <th>Geographic area</th>
        <th>Citation</th>
        <th>Trash</th>
        <th>Radial annotator</th>
        <th>Source/Otu clone</th>
        <th>Source/Geo clone</th>
        <th>OTU/Geo load</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.assertedDistributions"
        :key="item.id"
      >
        <td>
          <a
            :href="browseOtu(item.otu_id)"
            v-html="item.otu.object_tag"
          />
        </td>
        <td v-html="item.geographic_area.name" />
        <td v-if="item.citations.length > 1">
          <CitationCount :citations="item.citations" />
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
            @click="() => setSourceOtu(item)"
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
            @click="() => setGeoOtu(item)"
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

const store = useStore()

const emit = defineEmits(['onOtuGeo', 'onSourceGeo', 'onSourceOtu', 'remove'])

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

function browseOtu(id) {
  return `${RouteNames.BrowseOtu}?otu_id=${id}`
}

function setSourceOtu(item) {
  store.reset()
  setCitation(item.citations[0])
  store.otu = item.otu
}

function setSourceGeo(item) {
  store.reset()
  setCitation(item.citations[0])
  store.geographicArea = item.geographic_area
  store.isAbsent = item.is_absent
}

function setGeoOtu(item) {
  store.reset()
  store.autosave = false
  store.assertedDistribution.id = item.id
  store.geographicArea = item.geographic_area
  store.otu = item.otu
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
</script>
<style scoped>
table,
td,
tr {
  position: relative !important;
}
</style>
