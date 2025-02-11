<template>
  <BlockLayout>
    <template #header>
      <h3>Citation</h3>
    </template>
    <template #body>
      <div class="flex-separate middle margin-medium-bottom">
        <div v-html="currentCitationLabel" />
        <div class="horizontal-right-content middle gap-small">
          <RadialAnnotator :global-id="store.selected.citation.global_id" />
          <VBtn
            color="destroy"
            circle
            @click="destroyCitation"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </div>
      </div>
      <hr class="divisor" />
      <CitationTopics />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import CitationTopics from './CitationTopics.vue'
import useStore from '../../../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { computed } from 'vue'

const currentCitationLabel = computed(
  () =>
    store.selected.citation.citation_object.object_tag +
    ' in ' +
    store.selected.citation.source.author_year
)

const store = useStore()

function destroyCitation() {
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure want to proceed?`
    )
  ) {
    store.destroyCurrentCitation()
  }
}
</script>
