<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="item in documents"
        :key="item.id">
        <a
          data-icon="download"
          :href="item.document.file_url">
          pdf
        </a>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetDocumentsFromSourceID } from '../request/resources.js'

export default {
  props: {
    sourceId: {
      type: [String, Number]
    }
  },
  data() {
    return {
      documents: []
    }
  },
  mounted() {
    GetDocumentsFromSourceID(this.sourceId).then(response => {
      this.documents = response.body
    })
  }
}
</script>

<style>

</style>
