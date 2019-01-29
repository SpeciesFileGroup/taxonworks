<template>
  <table>
    <thead>
      <tr>
        <th>Otu</th>
        <th>Geographic area</th>
        <th>Source</th>
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
        <td v-html="item.otu.object_tag"/>
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
            @mouseover="emitHighlight(true, true, false)"
            @mouseout="emitHighlight(false, false, false)"
            @click="emitSourceOtu(item)">
            Clone
          </button>
        </td>
        <td>
          <button
            class="button normal-input button-default"
            type="button"
            @mouseover="emitHighlight(true, false, true)"
            @mouseout="emitHighlight(false, false, false)"
            @click="emitSourceGeo(item)">
            Clone
          </button>
        </td>
        <td>
          <button
            class="button normal-input button-default"
            type="button"
            @mouseover="emitHighlight(false, true, true)"
            @mouseout="emitHighlight(false, false, false)"
            @click="emitRecord(item)">
            Load
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'
import CitationCount from './citationsCount'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    CitationCount,
    RadialAnnotator
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  },
  methods: {
    nomenclatureBySourceRoute(id) {
      return `${RouteNames.NomenclatureBySource}/${id}`
    },
    removeItem(item) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('remove', item)
      }
    },
    emitSourceOtu(item) {
      let data = {
        citation: item.citations[0],
        otu: item.otu
      }
      this.$emit('onSourceOtu', data)
    },
    emitSourceGeo(item) {
      let data = {
        citation: item.citations[0],
        geo: item.geographic_area
      }
      this.$emit('onSourceGeo', data)
    },
    emitRecord(item) {
      let data = {
        id: item.id,
        otu: item.otu,
        geo: item.geographic_area
      }
      this.$emit('onOtuGeo', data) 
    },
    emitHighlight(source, otu, geo) {
      this.$emit('highlight', { 
        source: source, 
        otu: otu,
        geo: geo
      })
    }
  }

}
</script>
<style>
 table,td,tr {
   position: relative !important;
 }
</style>
