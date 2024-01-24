<template>
  <Navbar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <Autocomplete
          url="/field_occurrences/autocomplete"
          param="term"
          placeholder="Search"
          label="label_html"
          clear-after
          @get-item="({ id }) => loadForms(id)"
        />
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
            medium
            :disabled="!validateSave"
            @click="save"
          >
            Save
          </VBtn>
          <VBtn
            medium
            color="create"
            :disabled="!validateSave"
            @click="saveAndNew"
          >
            Save and new
          </VBtn>
          <VBtn
            medium
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
import Autocomplete from '@/components/ui/Autocomplete.vue'
import Navbar from '@/components/layout/NavBar.vue'
import useFieldOccurrenceStore from '../store/fieldOccurrence.js'
import useCitationStore from '../store/citations.js'
import useCEStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useDeterminationStore from '../store/determinations.js'
import useSettingStore from '../store/settings.js'
import useBiocurationStore from '../store/biocurations.js'
import useIdentifierStore from '../store/identifier.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import useHotkey from 'vue3-hotkey'
import platformKey from '@/helpers/getPlatformKey'
import { setParam } from '@/helpers'
import { computed, onBeforeMount, watch, ref } from 'vue'
import { FIELD_OCCURRENCE } from '@/constants'

const foStore = useFieldOccurrenceStore()
const settings = useSettingStore()
const citationStore = useCitationStore()
const determinationStore = useDeterminationStore()
const ceStore = useCEStore()
const biocurationStore = useBiocurationStore()
const identifierStore = useIdentifierStore()
const fieldOccurrenceId = computed(() => foStore.fieldOccurrence.id)
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
  try {
    const ce = ceStore.isUnsaved
      ? (await ceStore.save()).body
      : ceStore.collectingEvent

    foStore.fieldOccurrence.collecting_event_id = ce.id

    const { body } = await foStore.save()
    const args = {
      objectId: body.id,
      objectType: FIELD_OCCURRENCE
    }
    const requests = [
      citationStore.save(args),
      determinationStore.load(args),
      biocurationStore.save(args),
      identifierStore.save(args)
    ]

    return Promise.all(requests).then((_) => {
      TW.workbench.alert.create(
        'Field occurrence was successfully saved.',
        'notice'
      )
    })
  } catch (e) {}
}

function reset() {
  const { locked } = settings

  foStore.$reset()

  if (!locked.collectingEvent) {
    ceStore.reset()
  }

  if (locked.biocurations) {
    biocurationStore.resetIds()
  } else {
    biocurationStore.list = []
  }

  identifierStore.reset({ keepNamespace: locked.namespace })
  determinationStore.reset({ keepRecords: locked.taxonDeterminations })
  citationStore.reset({ keepRecords: locked.citations })
}

async function saveAndNew() {
  await save()
  reset()
}

watch(fieldOccurrenceId, (newVal, oldVal) => {
  if (newVal !== oldVal) {
    setParam(
      '/tasks/field_occurrences/new_field_occurrences',
      'field_occurrence_id',
      newVal
    )
  }
})

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('field_occurrence_id')

  if (/^\d+$/.test(id)) {
    loadForms(id)
  }
})

function loadForms(id) {
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
  citationStore.load(args)
  identifierStore.load(args)
}

const hotkeys = ref([
  {
    keys: [platformKey(), 's'],
    preventDefault: true,
    handler() {
      if (validateSave.value) {
        save()
      }
    }
  },
  {
    keys: [platformKey(), 'n'],
    preventDefault: true,
    handler() {
      if (validateSave.value) {
        saveAndNew()
      }
    }
  },
  {
    keys: [platformKey(), 'r'],
    preventDefault: true,
    handler() {
      reset()
    }
  }
])

const stop = useHotkey(hotkeys.value)

TW.workbench.keyboard.createLegend(
  `${platformKey()}+s`,
  'Save',
  'New field occurrence'
)
TW.workbench.keyboard.createLegend(
  `${platformKey()}+n`,
  'Save and new',
  'New field occurrence'
)
TW.workbench.keyboard.createLegend(
  `${platformKey()}+r`,
  'Reset all',
  'New field occurrence'
)
</script>
