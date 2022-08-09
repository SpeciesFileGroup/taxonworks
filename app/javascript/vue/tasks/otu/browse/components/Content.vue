<template>
  <section-panel
    :status="status"
    :title="title"
  >
    <div class="separate-top">
      <ul>
        <li
          v-for="content in contents"
          :key="content.id"
        >
          <b><span v-html="content.topic.name" /></b>
          <p
            class="pre"
            v-html="markdownToHtml(content.text)"
          />
        </li>
      </ul>
    </div>
  </section-panel>
</template>

<script>

import { Content } from 'routes/endpoints'
import SectionPanel from './shared/sectionPanel'
import extendSection from './shared/extendSections'
import EasyMDE from 'easymde/dist/easymde.min.js'
import DOMPurify from 'dompurify'

export default {
  mixins: [extendSection],

  components: { SectionPanel },

  props: {
    otu: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      contents: []
    }
  },

  watch: {
    otu: {
      handler (newVal) {
        if (newVal) {
          Content.where({
            otu_id: this.otu.id,
            most_recent_updates: 100,
            extend: ['topic']
          }).then(response => {
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
