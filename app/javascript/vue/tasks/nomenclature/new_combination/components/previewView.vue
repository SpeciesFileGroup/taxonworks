<template>
  <div class="new-combination-preview header">
    <h3
      class="horizontal-center-content"
      v-if="combination">
      <span>
        <i>
          <span
            v-for="rank in Object.keys(combination.protonyms)"
            :key="rank">
            <template v-if="combination.protonyms[rank]">
              {{ combination.protonyms[rank].name }}
            </template>
          </span>
        </i>
        <template v-if="incomplete">
          <span class="feedback feedback-warning feedback-thin margin-small-left margin-small-right">
            <span
              title="Match incomplete"
              data-icon="warning"/>
            Incomplete match
          </span>
        </template>
        <span v-html="showAuthorCitation(searchLastExistingRank(combination.protonyms))"/>
      </span>
      <span class="separate-left separate-right"> | </span>
      <edit-in-place
        legend="Click to edit verbatim"
        v-model="verbatimField"/>
      <tippy-component
        v-if="verbatimField"
        animation="scale"
        placement="bottom"
        size="small"
        inertia
        arrow
        content="Verbatim representations are for display purposes only, only use them as a last resort. Legitimate reasons may include gender agreement errors. You should likely create a new name and treat it as a misspelling or low level synonym. Creating a new name gives you more power and flexibility in downstream search and display. Do NOT use this to include comon, or temporary names whose use was not intended to be governed by a code of nomenclature">
        <template slot="trigger">
          <v-icon
            class="margin-small-left"
            name="attention"
            color="attention"
            small
          />
        </template>
      </tippy-component>
    </h3>
  </div>
</template>
<script>

import EditInPlace from 'components/editInPlace.vue'
import { TippyComponent } from 'vue-tippy'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    TippyComponent,
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
  data () {
    return {
      verbatimField: ''
    }
  },
  watch: {
    verbatimField (newVal) {
      this.$emit('onVerbatimChange', newVal)
    }
  },
  mounted () {
    this.verbatimField = this.combination.verbatim_name
  },
  methods: {
    searchLastExistingRank (combination) {
      return combination[Object.keys(combination).find((key) => {
        return combination[key]
      })]
    },
    showAuthorCitation (taxon) {
      return taxon?.origin_citation?.citation_source_body || undefined
    }
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
  h3 {
   font-weight: 300;
 }
 padding: 1em;
 padding-left: 1.5em;
 border-left: none;

 border-bottom: 1px solid #f5f5f5;
}
</style>
