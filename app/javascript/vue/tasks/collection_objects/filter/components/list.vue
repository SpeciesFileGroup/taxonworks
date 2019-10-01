<template>
  <div class="full_width">
    <table class="full_width">
      <thead>
        <tr>
          <th
            @click="sortTable('catalogNumber')">Catalogue number</th>
          <th
            @click="sortTable('repository')">Repository</th>
          <th
            @click="sortTable('family')">Family</th>
          <th
            @click="sortTable('genus')">Genus</th>
          <th
            @click="sortTable('species')">Species</th>
          <th
            @click="sortTable('country')">Country</th>
          <th
            @click="sortTable('state')">State</th>
          <th
            @click="sortTable('county')">County</th>
          <th
            @click="sortTable('locality')">Locality</th>
          <th
            @click="sortTable('latitude')">Latitude</th>
          <th
            @click="sortTable('longitude')">Longitude</th>
          <th
            @click="sortTable('updated_by')">Updated by</th>
          <th
            @click="sortTable('updated_at')">Last updated</th>
          <th>Options</th>
        </tr>
      </thead>
      <tbody>
        <tr
          class="contextMenuCells"
          :class="{ even: index % 2 }"
          v-for="(item, index) in list"
          :key="item.id">
          <td>{{ item.catalogNumber }}</td>
          <td>{{ item.repository_id }}</td>
          <td>{{ item.family }}</td>
          <td>{{ item.genus }}</td>
          <td>{{ item.scientificName }}</td>
          <td>{{ item.country }}</td>
          <td>{{ item.stateProvince }}</td>
          <td>{{ item.county }}</td>
          <td>{{ item.locality }}</td>
          <td>{{ item.decimalLatitude }}</td>
          <td>{{ item.decimalLongitude }}</td>
          <td>{{ item.updated_by }}</td>
          <td>{{ item.updated_at }}</td>
          <td class="options-column">
            <div class="horizontal-left-content">
              <radial-object :global-id="item.global_id"/>
              <radial-annotator
                type="annotations"
                :global-id="item.global_id"/>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <span
      v-if="list.length"
      class="horizontal-left-content">{{ list.length }} records.
    </span>
  </div>
</template>

<script>

import RadialAnnotator from 'components/annotator/annotator'
import RadialObject from 'components/radial_object/radialObject'

export default {
  components: {
    RadialAnnotator,
    RadialObject
  },
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    }
  },
  data () {
    return {
      ascending: false
    }
  },
  methods: {
    sortTable (sortProperty) {
      function compare (a,b) {
        if (a[sortProperty] < b[sortProperty])
          return (this.ascending ? -1 : 1)
        if (a[sortProperty] > b[sortProperty])
          return (this.ascending ? 1 : -1)
        return 0
      }
      this.list.sort(compare)
      this.ascending = !this.ascending
    }
  }
}
</script>

<style lang="scss" scoped>
  table {
    margin-top: 0px;
  }
  tr {
    height: 44px;
  }
  .options-column {
    width: 130px;
  }
</style>
