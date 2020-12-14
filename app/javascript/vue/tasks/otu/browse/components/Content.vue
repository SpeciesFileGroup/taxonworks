<template>
  <section-panel
    :status="status"
    :title="title">
    <div class="separate-top">
      <ul>
        <li
          v-for="content in contents"
          :key="content.id">
          <b><span v-html="content.topic.name"/></b>
          <p 
            class="pre"
            v-html="markdownToHtml(content.text)"/>
        </li>
      </ul>
    </div>
  </section-panel>
</template>

<script>

import { GetContent } from '../request/resources.js'
import SectionPanel from './shared/sectionPanel'
import extendSection from './shared/extendSections'
import EasyMDE from 'easymde'
import DOMPurify from 'dompurify'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
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
  },
  methods: {
    markdownToHtml (text) {
      const markdown = new EasyMDE()
      return DOMPurify.sanitize(markdown.options.previewRender(text))
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
