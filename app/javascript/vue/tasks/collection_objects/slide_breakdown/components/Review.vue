<template>
  <div class="panel content">
    <spinner-component
      v-if="isLoading"
      :show-spinner="false"/>
    <h2>Existing data</h2>
    <div style="overflow-x: scroll">
      <table>
        <thead>
          <tr>
            <th>Radial annotator</th>
            <th>Quick forms</th>
            <th>Edit</th>
            <th>Total</th>
            <th>Family</th>
            <th>Genus</th>
            <th>Scientific name</th>
            <th>Identifier</th>
            <th>Biocuration attributes</th>
            <th>Level 1</th>
            <th>Level 2</th>
            <th>Level 3</th>
            <th>Verbatim locality</th>
            <th>Date start</th>
            <th>Container</th>
            <th>Update at</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in list"
            :key="item.id"
            class="contextMenuCells"
            :class="{ 'even': (index % 2 == 0) }"
          >
            <td>
              <radial-annotator :global-id="item.global_id"/>
            </td>
            <td>
              <radial-object
                button-class="btn-co-radial"
                :global-id="item.global_id"/>
            </td>
            <td>
              <radial-navigation :global-id="item.global_id"/>
            </td>
            <td>{{ item.dwc_attributes.individualCount }}</td>
            <td>{{ item.dwc_attributes.family }}</td>
            <td>{{ item.dwc_attributes.genus }}</td>
            <td>{{ item.dwc_attributes.scientificName }}</td>
            <td
              v-if="item.identifier_from_container"
              v-html="item.object_tag"/>
            <td v-else>{{ item.dwc_attributes.catalogNumber}}</td>
            <td>{{ item.biocuration }}</td>
            <td>{{ item.dwc_attributes.country }}</td>
            <td>{{ item.dwc_attributes.stateProvince }}</td>
            <td>{{ item.dwc_attributes.county }}</td>
            <td>{{ item.dwc_attributes.verbatimLocality }}</td>
            <td>{{ item.dwc_attributes.eventDate }}</td>
            <td v-html="item.container"/>
            <td>{{ item.updated_at }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialNavigation from 'components/radials/navigation/radial'
import RadialObject from 'components/radials/object/radial'
import { Report } from '../request/resource'
import { GetterNames } from '../store/getters/getters'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    RadialNavigation,
    RadialAnnotator,
    SpinnerComponent,
    RadialObject
  },

  computed: {
    sledImage () {
      return this.$store.getters[GetterNames.GetSledImage]
    }
  },

  data () {
    return {
      list: [],
      isLoading: false
    }
  },

  mounted () {
    if (this.sledImage.id) {
      this.isLoading = true
      Report(this.sledImage.id).then(response => {
        this.list = response.body
      }).finally(_ => {
        this.isLoading = false
      })
    }
  }
}
</script>
