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
      <a 
        :href="citation.citation_object.object_url"
        v-html="citation.citation_object.object_tag"
      />
    </td>
    <td>
      <div class="horizontal-right-content">
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
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import useRow from '../../composables/useRow'

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

</script>