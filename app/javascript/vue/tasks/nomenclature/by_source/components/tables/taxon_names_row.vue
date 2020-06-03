<template>
  <tr>
    <td>
      <input
        class="pages"
        type="text"
        placeholder="Pages"
        @input="updatePage"
        v-model="citation.pages"
      >
    </td>
    <td>
      <input
        v-model="citation.is_original"
        @change="updateCitation"
        type="checkbox"
      >
    </td>
    <td>
      <a
        v-html="citation.citation_object.original_combination"
        :href="`/tasks/nomenclature/browse?taxon_name_id=${citation.citation_object_id}`"
      />
      <span v-html="isInvalid" />
    </td>
    <td>
      <span v-html="citation.citation_object.type" />
    </td>
    <td>
      <confidence-button :global-id="citation.citation_object.global_id" />
    </td>
    <td>
      <radial-annotator :global-id="citation.citation_object.global_id" />
    </td>
    <td>
      <span
        class="button circle-button btn-delete"
        @click="removeMe()"
      />
    </td>
  </tr>
</template>

<script>

import RadialAnnotator from 'components/radials/annotator/annotator'
import ConfidenceButton from 'components/defaultConfidence.vue'
import extendedRow from './extendedRow.js'

export default {
  mixins: [extendedRow],
  components: {
    RadialAnnotator,
    ConfidenceButton
  },
  props: {
    citation: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      pages: undefined,
      autoSave: undefined,
      time: 3000
    }
  },
  computed: {
    isInvalid () {
      return (this.citation.citation_object.id === this.citation.citation_object.cached_valid_taxon_name_id) ? '✓' : '❌'
    }
  }
}
</script>
<style lang="scss" module>
  .pages {
    width: 80px;
  }
  .validity {
    width: 40px;
  }
</style>
