<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="item in documents"
        :key="item.id">
        <a
          class="btn-download circle-button"
          :href="item.document.file_url"
          download
        />
      </li>
    </ul>
  </div>
</template>

<script>

import { Source } from 'routes/endpoints'

export default {
  props: {
    sourceId: {
      type: [String, Number]
    }
  },

  data () {
    return {
      documents: []
    }
  },

  mounted () {
    Source.documentation(this.sourceId).then(response => {
      this.documents = response.body
    })
  }
}
</script>
