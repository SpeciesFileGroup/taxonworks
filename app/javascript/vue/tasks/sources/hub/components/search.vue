<template>
  <div>
    <h3 class="title-section">Search</h3>
    <div class="panel content">
      <autocomplete
        url="/sources/autocomplete"
        param="term"
        label="label_html"
        @getItem="loadSource"
        placeholder="Select a source"/>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  methods: {
    loadSource(source) {
      window.open(`/sources/${source.id}`)
    }
  }
}
</script>

<style>

</style>
