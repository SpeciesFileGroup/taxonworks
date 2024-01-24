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
        <li class="horizontal-right-content gap-small">
          <span
            v-if="isUnsaved"
            class="medium-icon margin-small-right"
            title="You have unsaved changes."
            data-icon="warning"
          />
          <VBtn
            color="create"
            :disabled="!validateSave"
            @click="save"
          >
            Save
          </VBtn>
          <VBtn
            color="create"
            :disabled="!validateSave"
          >
            Save and new
          </VBtn>
          <VBtn
            color="primary"
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
import useBiocurationStore from '../store/biocurations.js'
import useIdentifierStore from '../store/identifier.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import { computed, onBeforeMount } from 'vue'
import { FIELD_OCCURRENCE } from '@/constants'

const foStore = useFieldOccurrenceStore()
const settings = useSettingStore()
const citationStore = useCitationStore()
const determinationStore = useDeterminationStore()
const ceStore = useCEStore()
const biocurationStore = useBiocurationStore()
const identifierStore = useIdentifierStore()
const isUnsaved = computed(
  () =>
    citationStore.hasUnsaved ||
    determinationStore.hasUnsaved ||
    biocurationStore.hasUnsaved ||
    foStore.fieldOccurrence.isUnsaved ||
    ceStore.collectingEvent.isUnsaved ||
    identifierStore.isUnsaved
)

const validateSave = computed(() => {
  return (
    determinationStore.determinations.length &&
    (ceStore.collectingEvent.isUnsaved || ceStore.collectingEvent.id)
  )
})

async function save() {
  const ce = ceStore.isUnsaved
    ? (await ceStore.save()).body
    : ceStore.collectingEvent

  foStore.fieldOccurrence.collecting_event_id = ce.id

  foStore
    .save()
    .then(({ body }) => {
      const args = {
        objectId: body.id,
        objectType: FIELD_OCCURRENCE
      }

      citationStore.save(args)
      determinationStore.load(args)
      biocurationStore.save(args)
      identifierStore.save(args)
    })
    .then(() => {
      TW.workbench.alert.create(
        'Field occurrence was successfully saved.',
        'notice'
      )
    })
}

function reset() {
  const { locked } = settings
  if (!locked.collectingEvent) {
    ceStore.reset()
  }

  if (locked.biocurations) {
    biocurationStore.resetIds()
  } else {
    biocurationStore.list = []
  }

  citationStore.$reset()
}

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('field_occurrence_id')

  if (/^\d+$/.test(id)) {
    const args = {
      objectId: id,
      objectType: FIELD_OCCURRENCE
    }

    foStore.load(id).then(({ body }) => {
      const ceId = body.collecting_event_id

      if (ceId) {
        ceStore.load(ceId)
      }
    })

    determinationStore.load(args)
    biocurationStore.load(args)
  }
})
</script>
