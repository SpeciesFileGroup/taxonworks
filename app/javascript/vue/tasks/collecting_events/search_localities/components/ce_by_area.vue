<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <h2>Find collecting events by named geographic area</h2>
    <div>
      <table>
        <tr
          v-for="(item, index) in geographicAreaList"
          :key="item.id">
          <td>
            <span v-html="item.label_html"/>
          </td>
          <td>
            <span
              class="remove_area"
              data-icon="trash"
              @click="deListArea(index)"
            />
          </td>
        </tr>
      </table>
      <autocomplete
        class="separate-bottom"
        url="/geographic_areas/autocomplete"
        min="2"
        ref="autocomplete"
        param="term"
        placeholder="Select a named geographic area"
        label="label_html"
        @getItem="addGeographicArea($event)"
        :autofocus="true"
        :clear-after="true"
      />
      <input
        type="button"
        class="button normal-input button-default"
        @click="getAreaData()"
        :disabled="!geographicAreaList.length"
        value="Find">
    </div>
  </div>
</template>
<script>
import Autocomplete from 'components/ui/Autocomplete'
import Spinner from 'components/spinner'
import { CollectingEvent } from 'routes/endpoints'

export default {
  components: {
    Autocomplete,
    Spinner
  },

  data () {
    return {
      geographicAreaList: [],
      collectingEventList: [],
      isLoading: false
    }
  },

  methods: {
    getAreaData () {
      const params = {
        geographic_area_ids: this.geographicAreaList.map(area => area.id),
        spatial_geographic_areas: true
      }

      this.isLoading = true
      CollectingEvent.where(params).then(response => {
        this.collectingEventList = response.body
        this.$emit('jsonUrl', response.request.responseURL)
        if (this.collectingEventList) {
          this.$emit('collectingEventList', this.collectingEventList)
        }
      }).finally(() => {
        this.isLoading = false
      })
    },

    addGeographicArea (item) {
      this.geographicAreaList.push(item)
    },

    deListArea (index) {
      this.$delete(this.geographicAreaList, index)
    }
  }
}
</script>
