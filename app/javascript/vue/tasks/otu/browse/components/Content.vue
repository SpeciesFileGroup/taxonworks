<template>
  <section-panel title="Content">
    <div class="separate-top">
      <ul>
        <li
          v-for="content in contents"
          :key="content.id">
          <b><span v-html="content.topic.name"/></b>
          <p 
            class="pre"
            v-html="content.text"/>
        </li>
      </ul>
    </div>
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
    margin-bottom: 12px;
  }
  li:last-child {
    border-bottom: none;
  }
  .pre {
    white-space: pre-wrap;
  }
</style>