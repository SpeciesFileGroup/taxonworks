<template>
  <div class="new-combination-preview header">
    <h3
      class="horizontal-center-content"
      v-if="combination"
    >
      <span>
        <i>{{ previewName }}</i>
        <template v-if="incomplete">
          <span
            class="feedback feedback-warning feedback-thin margin-small-left margin-small-right"
          >
            <span
              title="Match incomplete"
              data-icon="warning"
            />
            Incomplete match
          </span>
        </template>
        <span v-html="showAuthorCitation" />
      </span>
      <span class="separate-left separate-right"> | </span>
      <edit-in-place
        legend="Click to edit verbatim"
        v-model="verbatimField"
      />
      <tippy
        v-if="verbatimField"
        animation="scale"
        placement="bottom"
        size="small"
        inertia
        arrow
        content="Verbatim representations are for display purposes only, only use them as a last resort. Legitimate reasons may include gender agreement errors. You should likely create a new name and treat it as a misspelling or low level synonym. Creating a new name gives you more power and flexibility in downstream search and display. Do NOT use this to include comon, or temporary names whose use was not intended to be governed by a code of nomenclature"
      >
        <v-icon
          class="margin-small-left"
          name="attention"
          color="attention"
          small
        />
      </tippy>
    </h3>
  </div>
</template>
<script>
import EditInPlace from '@/components/editInPlace.vue'
import { Tippy } from 'vue-tippy'
import VIcon from '@/components/ui/VIcon/index.vue'

export default {
  components: {
    Tippy,
    EditInPlace,
    VIcon
  },

  props: {
    combination: {
      type: Object,
      default: undefined
    },

    incomplete: {
      type: Boolean,
      default: false
    }
  },

  emits: ['onVerbatimChange'],

  data() {
    return {
      verbatimField: ''
    }
  },

  computed: {
    previewName() {
      const names = Object.values(this.combination?.protonyms || {})

      return names
        .filter((rank) => rank)
        .map(({ name }) => name)
        .join(' ')
    },

    showAuthorCitation() {
      const lastTaxonRank = Object.values(this.combination.protonyms)
        .reverse()
        .find((combination) => combination)

      return lastTaxonRank?.origin_citation?.citation_source_body
    }
  },

  watch: {
    verbatimField(newVal) {
      this.$emit('onVerbatimChange', newVal)
    }
  },

  mounted() {
    this.verbatimField = this.combination.verbatim_name
  }
}
</script>
<style lang="scss" scoped>
.new-combination-preview {
  position: relative;
  .new-combination-preview-edit {
    position: absolute;
    right: 12px;
  }
}
.header {
  align-items: center;
  padding: 1em;
  padding-left: 1.5em;
  border-left: none;
  border-bottom: 1px solid var(--border-color);

  h3 {
    font-weight: 300;
  }
}
</style>
