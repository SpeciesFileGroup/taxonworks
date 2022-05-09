<template>
  <tr>
    <td>
      <input
        v-model="citation.pages"
        class="input-small-width"
        type="text"
        placeholder="Pages"
        @input="autosaveCitation"
      >
    </td>
    <td>
      <input
        v-model="citation.is_original"
        type="checkbox"
        @change="updateCitation"
      >
    </td>
    <td class="full_width">
      <a :href="`/tasks/nomenclature/browse?taxon_name_id=${citation.citation_object_id}`">
        <span v-html="citation.citation_object.original_combination" /> {{ isInvalid(citation.citation_object) }}
      </a>
    </td>
    <td>
      <div class="horizontal-right-content">
        <ConfidenceButton :global-id="citation.citation_object.global_id" />
        <RadialAnnotator :global-id="citation.citation_object.global_id" />
        <VBtn
          circle
          color="destroy"
          @click="removeCitation"
        >
          <VIcon
            x-small
            name="trash"
          />
        </VBtn>
      </div>
    </td>
  </tr>
</template>

<script setup>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import ConfidenceButton from 'components/defaultConfidence.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import useRow from '../../composables/useRow.js'
import { COMBINATION } from 'constants/index.js'

const props = defineProps({
  citation: {
    type: Object
  }
})

const {
  removeCitation,
  autosaveCitation,
  updateCitation
} = useRow(props.citation)

const isInvalid = taxon => {
  if (taxon.type === COMBINATION) {
    return '[c]'
  }

  return (taxon.cached_is_valid)
    ? '✓'
    : '❌'
}
</script>