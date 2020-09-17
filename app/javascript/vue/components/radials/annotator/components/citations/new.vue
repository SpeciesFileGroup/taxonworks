<template>
  <div>
    <div class="separate-bottom inline">
      <smart-selector
        class="full_width"
        model="sources"
        ref="smartSelector"
        pin-section="Sources"
        :klass="objectType"
        pin-type="Source"
        @selected="citation.source_id = $event.id; citation.author_year = getAuthorYear($event)"
        v-model="source">
        <div slot="footer">
          <div
            v-if="source"
            class="horizontal-left-content margin-medium-bottom margin-medium-top">
            <span
              v-html="source.object_tag"/>
            <span
              class="button circle-button btn-delete button-default"
              @click="unsetSource"/>
          </div>
          <ul class="no_bullets context-menu">
            <li>
              <input
                type="text"
                class="normal-input inline pages"
                v-model="citation.pages"
                placeholder="Pages">
            </li>
            <li>
              <label class="inline middle">
                <input
                  v-model="citation.is_original"
                  type="checkbox">
                Is original (does not apply to topics)
              </label>
            </li>
          </ul>
        </div>
      </smart-selector>
    </div>
    <div class="separate-bottom">
      <button
        class="button button-submit normal-input"
        :disabled="!validateFields"
        @click="sendCitation()"
        type="button">Create
      </button>
    </div>
  </div>
</template>

<script>
  import SmartSelector from 'components/smartSelector'

  export default {
    components: {
      SmartSelector
    },
    props: {
      globalId: {
        type: String,
        required: true
      },
      objectType: {
        type: String,
        required: true
      }
    },
    computed: {
      validateFields() {
        return this.citation.source_id
      }
    },
    data() {
      return {
        citation: this.newCitation(),
        source: undefined
      }
    },
    methods: {
      newCitation() {
        return {
          annotated_global_entity: decodeURIComponent(this.globalId),
          source_id: undefined,
          is_original: false,
          pages: undefined,
          citation_topics_attributes: [],
          author_year: undefined
        }
      },
      sendCitation() {
        this.$emit('create', this.citation)
        this.citation = this.newCitation()
        this.source = undefined
      },
      unsetSource () {
        this.citation.source_id = undefined,
        this.source = undefined
      },
      getAuthorYear (source) {
        return `${source.cached_author_string}, ${source.year}`
      }
    }
  }
</script>