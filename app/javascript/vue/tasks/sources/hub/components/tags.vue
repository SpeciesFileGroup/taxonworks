<template>
  <ul class="annotations__tag_list">
    <li 
      v-for="tag in tags"
      :key="tag.id">
      <span class="annotation__tag" v-html="tag.keyword.object_tag"/>
    </li>
  </ul>
</template>

<script>

import { GetSourceTags } from '../request/resources.js'

export default {
  props: {
    sourceId: {
      type: [String, Number]
    }
  },
  data() {
    return {
      tags: []
    }
  },
  mounted() {
    GetSourceTags(this.sourceId).then(response => {
      this.tags = response.body
    })
  }
}
</script>
