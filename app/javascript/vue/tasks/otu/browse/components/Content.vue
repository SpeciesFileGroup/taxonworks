<template>
  <section-panel title="Content">
    <ul class="no_bullets">
      <li
        v-for="content in contents"
        :key="content.id">
        <span v-html="content.topic.name"/>
        <p v-html="content.text"/>
      </li>
    </ul>
  </section-panel>
</template>

<script>

import { GetContent } from '../request/resources.js'
import SectionPanel from './shared/sectionPanel'

export default {
  components: {
    SectionPanel
  },
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
    otu: {
      handler (newVal) {
        if(newVal) {
          GetContent(this.otu.id).then(response => {
            this.contents = response.body
          })
        }
      },
      immediate: true
    }
  }
}
</script>
<style lang="scss" scoped>
  li {
    border-bottom: 1px solid #F5F5F5;
  }
</style>