<template>
  <div>
    <br>
    <autocomplete
      url="/taxon_names/autocomplete"
      placeholder="Select a taxon name"
      param="term"
      :input-style="{ width: '300px' }"
      @getItem="redirect"
      display="label"
      label="label_html"/>
    <label>
      <input
        v-model="validName"
        type="checkbox"> Redirect to valid name
    </label>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { RouteNames } from 'routes/routes'

const SettingsStore = {
  redirectValid: 'browseNomenclature::redirectValid'
}

export default {
  components: {
    Autocomplete
  },
  data () {
    return {
      validName: true
    }
  },
  watch: {
    validName: {
      handler (newVal) {
        sessionStorage.setItem(SettingsStore.redirectValid, newVal)
      }
    }
  },
  mounted () {
    const value = sessionStorage.getItem(SettingsStore.redirectValid)
    if (value !== null) {
      this.validName = value === 'true'
    }
  },
  methods: {
    redirect (event) {
      window.open(`${RouteNames.BrowseNomenclature}?taxon_name_id=${this.validName ? event.valid_taxon_name_id : event.id}`, '_self')
    }
  }
}
</script>
