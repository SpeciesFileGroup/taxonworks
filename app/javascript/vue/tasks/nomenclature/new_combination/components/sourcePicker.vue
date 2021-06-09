<template>
  <div class="new-combination-citation">
    <h3>Citation</h3>
    <div class="flex-separate middle">
      <template v-if="title">
        <a
          :href="`/sources/${origin_citation.source.id}/edit`"
          v-html="origin_citation.source.object_tag"/>
        <div class="horizontal-left-content">
          <input
            type="text"
            @input="sendCitation"
            v-model="pages"
            placeholder="Pages">
          <span
            class="circle-button btn-delete"
            @click="remove()"/>
        </div>
      </template>

      <template v-else>
        <smart-selector
          class="full_width"
          model="sources"
          ref="smartSelector"
          pin-section="Sources"
          pin-type="Source"
          @selected="setSource"
          v-model="source">
          <template #footer>
            <div>
              <span
                v-if="source"
                v-html="source.object_tag"/>
              <input
                type="text"
                @input="sendCitation"
                v-model="pages"
                placeholder="Pages">
            </div>
          </template>
        </smart-selector>
      </template>
    </div>
  </div>
</template>
<script>

import SmartSelector from 'components/ui/SmartSelector'

export default {
  components: {
    SmartSelector
  },
  props: {
    citation: {
      default: undefined
    }
  },

  emits: ['select'],

  data () {
    return {
      origin_citation: {},
      source: undefined,
      autocompleteLabel: undefined,
      title: undefined,
      pages: undefined,
      sourceId: undefined
    }
  },

  watch: {
    citation: {
      handler (newVal) {
        this.reset()
        this.origin_citation = newVal
        if (newVal) {
          this.pages = this.origin_citation.pages
          this.id = this.origin_citation.id
          this.title = this.origin_citation.source.object_tag
          this.sourceId = this.origin_citation.source_id
        }
      },
      immediate: true
    }
  },

  methods: {
    reset () {
      this.title = undefined
      this.pages = undefined
      this.sourceId = undefined
    },

    sendCitation () {
      this.$emit('select', {
        origin_citation_attributes: {
          id: this.origin_citation?.id,
          source_id: this.source.id,
          pages: this.pages
        }
      })
    },

    remove () {
      this.$emit('select', {
        origin_citation_attributes: {
          id: this.origin_citation?.id,
          _destroy: true
        }
      })
      this.title = undefined
    },

    setSource (source) {
      this.source = source
      this.sendCitation()
    }
  }
}

</script>
