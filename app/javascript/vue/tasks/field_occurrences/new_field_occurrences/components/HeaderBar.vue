<template>
  <Navbar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <span
          v-if="foStore.fieldOccurrence.id"
          class="margin-small-left"
          v-html="foStore.fieldOccurrence.object_tag"
        />
        <span
          class="margin-small-left"
          v-else
        >
          New record
        </span>
        <div
          v-if="foStore.fieldOccurrence.id"
          class="horizontal-left-content margin-small-left gap-small"
        >
          <RadialAnnotator :global-id="foStore.fieldOccurrence.global_id" />
          <RadialObject :global-id="foStore.fieldOccurrence.global_id" />
        </div>
      </div>
      <ul class="context-menu no_bullets">
        <li class="horizontal-right-content">
          <span
            v-if="isUnsaved"
            class="medium-icon margin-small-right"
            title="You have unsaved changes."
            data-icon="warning"
          />
          <VBtn
            class="button normal-input button-submit button-size margin-small-right"
            @click="save"
          >
            Save
          </VBtn>
          <VBtn
            class="button normal-input button-default button-size"
            @click="reset"
          >
            New
          </VBtn>
        </li>
      </ul>
    </div>
  </Navbar>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import Navbar from '@/components/layout/NavBar.vue'
import useFieldOccurrenceStore from '../store/fieldOccurrence.js'
import useCitationStore from '../store/citations.js'
import useCEStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useDeterminationStore from '../store/determinations.js'
import useSettingStore from '../store/settings.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed } from 'vue'

const foStore = useFieldOccurrenceStore()
const settings = useSettingStore()
const citationStore = useCitationStore()
const determinationStore = useDeterminationStore()
const ceStore = useCEStore()
const isUnsaved = computed(
  () =>
    citationStore.hasUnsaved ||
    determinationStore.hasUnsaved ||
    foStore.fieldOccurrence.isUnsaved ||
    ceStore.collectingEvent.isUnsaved
)

function save() {}

function reset() {
  if (!settings.locked.collectingEvent) {
    ceStore.reset()
  }

  citationStore.$reset()
}
</script>
