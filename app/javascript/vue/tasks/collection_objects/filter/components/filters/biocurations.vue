<template>
  <div>
    <h3>Biocurations</h3>
    <ul class="no_bullets">
      <li
        v-for="item in biocurations"
        :key="item.id"
        class="margin-small-bottom">
        <label>
          <input
            type="checkbox"
            v-model="selectedBiocurations"
            :value="item.id">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetBiocurations } from '../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    selectedBiocurations: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      biocurations: []
    }
  },
  mounted () {
    GetBiocurations().then(response => {
      this.biocurations = response.body
    })
    const urlParams = URLParamsToJSON(location.href)
    this.selectedBiocurations = urlParams.biocuration_class_ids ? urlParams.biocuration_class_ids : []
  }
}
</script>
