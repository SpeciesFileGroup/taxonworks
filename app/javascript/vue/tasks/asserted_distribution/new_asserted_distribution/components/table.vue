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
        v-for="item in list"
        :key="item.id">
        <td>
          <a
            :href="browseOtu(item.otu.id)"
            v-html="item.otu.object_tag"/>
        </td>
        <td v-html="item.geographic_area.name"/>
        <template>
          <td v-if="item.citations.length > 1">
            <citation-count :citations="item.citations"/>
          </td>
          <td v-else>
            <a
              target="blank"
              :href="nomenclatureBySourceRoute(item.citations[0].source.id)"
              v-html="item.citations[0].citation_source_body"/>
            <soft-validation
              class="margin-small-left"
              :global-id="item.global_id"/>
          </td>
        </template>
        <td>
          <span 
            class="button circle-button btn-delete"
            @click="removeItem(item)"/>
        </td>
        <td>
          <radial-annotator
            type="annotations"
            :global-id="item.global_id"
          />
        </td>
        <td>
          <button
            class="button normal-input button-default"
            type="button"
            @click="$emit('onSourceOtu', item)">
            Clone
          </button>
        </td>
        <td>
          <button
            class="button normal-input button-default"
            type="button"
            @click="$emit('onSourceGeo', item)">
            Clone
          </button>
        </td>
        <td>
          <button
            class="button normal-input button-default"
            type="button"
            @click="$emit('onOtuGeo', item)">
            Load
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import CitationCount from './citationsCount'
import { RouteNames } from 'routes/routes'
import SoftValidation from 'components/soft_validations/objectValidation.vue'

export default {
  components: {
    CitationCount,
    RadialAnnotator,
    SoftValidation
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  },
  methods: {
    nomenclatureBySourceRoute(id) {
      return `${RouteNames.NomenclatureBySource}?source_id=${id}`
    },
    removeItem(item) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('remove', item)
      }
    },
    browseOtu(id) {
      return `${RouteNames.BrowseOtu}?otu_id=${id}`
    }
  }

}
</script>
<style scoped>
 table,td,tr {
   position: relative !important;
 }
</style>
