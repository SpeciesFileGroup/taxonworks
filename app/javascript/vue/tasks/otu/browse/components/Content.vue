<template>
  <div class="panel content">
    <h3>Content</h3>
    <ul class="no_bullets">
      <li v-for="content in contents">
        <span v-html="content.topic.name"/>
        <p v-html="content.text"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetContent } from '../request/resources.js'

export default {
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      contents: []
    }
  },
  watch: {
    otu(newVal) {
      if(newVal) {
        GetContent(this.otu.id).then(response => {
          this.contents = response.body
        })
      }
    }
  }
}
</script>
<style lang="scss" scoped>
  li {
    border-bottom: 1px solid #F5F5F5;
  }
</style>