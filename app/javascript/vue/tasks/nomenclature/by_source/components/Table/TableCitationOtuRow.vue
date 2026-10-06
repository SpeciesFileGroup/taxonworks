<template>
  <tr>
    <td>
      <input
        v-model="citation.pages"
        class="input-small-width"
        type="text"
        placeholder="Pages"
        @input="autosaveCitation"
      />
    </td>
    <td>
      <input
        v-model="citation.is_original"
        type="checkbox"
        @change="updateCitation"
      />
    </td>
    <td class="full_width">
      <template v-if="relatedObjects.length > 1">
        <template
          v-for="(relatedObject, index) in relatedObjects"
          :key="`${index}-${relatedObject.base_class}-${relatedObject.id}`"
        >
          <span
            v-if="index"
            class="notice"
          >
            {{ citation.relationshipLabel }}
          </span>
          <a
            :href="urlFor(relatedObject)"
            v-html="relatedObject.object_tag"
          />
        </template>
      </template>
      <a
        v-else
        :href="objectUrl"
        v-html="citation.citation_object.object_tag"
      />
    </td>
    <td>
      <div class="horizontal-right-content gap-small">
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
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import useRow from '../../composables/useRow'
import { computed } from 'vue'
import { RouteNames } from '@/routes/routes'
import { OTU } from '@/constants/index.js'

const props = defineProps({
  citation: {
    type: Object
  }
})

const { removeCitation, autosaveCitation, updateCitation } = useRow(
  props.citation
)

const relatedObjects = computed(() => props.citation.relatedObjects || [])

// A single related object keeps the citation object's own tag as the link
// label, so that the context it carries (e.g. the area of an asserted
// distribution) is not lost.
const objectUrl = computed(() =>
  relatedObjects.value.length
    ? urlFor(relatedObjects.value[0])
    : props.citation.citation_object.object_url
)

// Both asserted distributions and biological associations point to polymorphic
// objects, so fall back to the object's own page when it is not an OTU.
function urlFor(relatedObject) {
  return relatedObject.base_class === OTU
    ? `${RouteNames.BrowseOtu}?otu_id=${relatedObject.id}`
    : relatedObject.object_url
}
</script>
