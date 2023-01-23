<template>
  <div>
    <textarea
      v-model="text"
      class="full_width"
      placeholder="Identifiers, one per line."
      rows="10"
    />
  </div>
</template>

<script>
import { URLParamsToJSON } from 'helpers/url/parse'

export default {
  emits: ['lines'],

  data() {
    return {
      text: undefined
    }
  },

  watch: {
    text(newVal) {
      this.$emit(
        'lines',
        newVal.split('\n').filter((line) => line.trim().length)
      )
    }
  },

  created() {
    const urlParams = URLParamsToJSON(location.href)
    const coIds = urlParams.collection_object_id || []
    const identifierIds = urlParams.identifier_id || []

    this.text = [...coIds, ...identifierIds].join('\n')
  }
}
</script>
