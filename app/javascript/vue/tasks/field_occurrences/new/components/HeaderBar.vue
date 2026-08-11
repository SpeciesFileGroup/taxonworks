<template>
  <Navbar>
    <div class="flex-separate full_width">
      <div class="horizontal-left-content gap-medium middle">
        <AutocompletePopover
          ref="autocomplete"
          url="/field_occurrences/autocomplete"
          param="term"
          placeholder="Search"
          label="label_html"
          clear-after
          min="1"
          medium
          title="Search a field occurrence"
          @select="({ id }) => loadForms(id)"
        />
        <span
          v-if="foStore.fieldOccurrence.id"
          v-html="foStore.fieldOccurrence.object_tag"
        />
        <span v-else> New record </span>
        <div
          v-if="foStore.fieldOccurrence.id"
          class="horizontal-left-content gap-small"
        >
          <RadialAnnotator :global-id="foStore.fieldOccurrence.global_id" />
          <RadialObject :global-id="foStore.fieldOccurrence.global_id" />
          <RadialNavigator :global-id="foStore.fieldOccurrence.global_id" />
        </div>
      </div>
      <div class="horizontal-right-content gap-medium">
        <UnsavedIndicator v-if="isUnsaved" />
        <div class="horizontal-right-content gap-small">
          <VBtn
            medium
            color="create"
            :disabled="!validateSave"
            @click="save"
          >
            Save
          </VBtn>
          <VBtn
            medium
            color="create"
            variant="tonal"
            :disabled="!validateSave"
            @click="saveAndNew"
          >
            Save and new
          </VBtn>
          <VBtn
            medium
            color="primary"
            variant="tonal"
            @click="reset"
          >
            New
          </VBtn>
        </div>
        <div class="horizontal-right-content gap-small">
          <VRecent @selected="({ id }) => loadForms(id)" />
          <LayoutConfiguration />
        </div>
      </div>
    </div>
  </Navbar>
  <VSpinner
    v-if="settings.isSaving || settings.isLoading"
    full-screen
  />
</template>

<script setup>
import { computed, onBeforeMount, watch, ref, useTemplateRef } from 'vue'
import { setParam, smartSelectorRefresh } from '@/helpers'
import { FIELD_OCCURRENCE } from '@/constants'
import { useHotkey } from '@/composables'

import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import AutocompletePopover from '@/components/ui/Autocomplete/AutocompletePopover.vue'
import Navbar from '@/components/layout/NavBar.vue'
import useFieldOccurrenceStore from '../store/fieldOccurrence.js'
import useCitationStore from '../store/citations.js'
import useCEStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import useDeterminationStore from '../store/determinations.js'
import useSettingStore from '../store/settings.js'
import useBiocurationStore from '../store/biocurations.js'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations.js'
import useDepictionStore from '../store/depictions.js'
import useOriginRelationshipStore from '../store/originRelationships.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import UnsavedIndicator from '@/components/ui/UnsavedIndicator/UnsavedIndicator.vue'
import VRecent from './Recent.vue'
import LayoutConfiguration from './LayoutConfiguration.vue'
import platformKey from '@/helpers/getPlatformKey'
import VSpinner from '@/components/ui/VSpinner.vue'

const foStore = useFieldOccurrenceStore()
const settings = useSettingStore()
const citationStore = useCitationStore()
const determinationStore = useDeterminationStore()
const biologicalAssociationStore = useBiologicalAssociationStore()
const ceStore = useCEStore()
const biocurationStore = useBiocurationStore()
const depictionStore = useDepictionStore()
const originRelationshipStore = useOriginRelationshipStore()
const autocompleteRef = useTemplateRef('autocomplete')
const fieldOccurrenceId = computed(() => foStore.fieldOccurrence.id)
const isUnsaved = computed(
  () =>
    originRelationshipStore.hasUnsaved ||
    citationStore.hasUnsaved ||
    determinationStore.hasUnsaved ||
    biocurationStore.hasUnsaved ||
    foStore.fieldOccurrence.isUnsaved ||
    ceStore.isUnsaved
)

const validateSave = computed(() => {
  return (
    determinationStore.determinations.length &&
    (ceStore.isUnsaved || ceStore.collectingEvent.id)
  )
})

async function save() {
  try {
    settings.isSaving = true

    if (ceStore.isUnsaved) {
      await ceStore.save()
    }

    foStore.fieldOccurrence.collecting_event_id = ceStore.collectingEvent.id

    const { body } = await foStore.save()
    const args = {
      objectId: body.id,
      objectType: FIELD_OCCURRENCE
    }
    const requests = [
      citationStore.save(args),
      determinationStore.load(args),
      biocurationStore.save(args),
      originRelationshipStore.save(args),
      biologicalAssociationStore.save(args)
    ]

    return Promise.all(requests)
      .then(() => {
        TW.workbench.alert.create(
          'Field occurrence was successfully saved.',
          'notice'
        )
      })
      .catch(() => {})
      .finally(async () => {
        smartSelectorRefresh()
        await foStore.load(body.id)
        settings.isSaving = false
      })
  } catch {
    settings.isSaving = false
  }
}

function reset() {
  const { locked } = settings

  foStore.$reset()

  if (!locked.collectingEvent) {
    ceStore.reset()
  }

  biocurationStore.reset({ keepRecords: locked.biocurations })
  originRelationshipStore.$reset()
  depictionStore.$reset()
  determinationStore.reset({ keepRecords: locked.taxonDeterminations })
  citationStore.reset({ keepRecords: locked.citations })
  biologicalAssociationStore.reset({
    keepRecords: locked.biologicalAssociation.list
  })
}

async function saveAndNew() {
  await save()
  reset()
}

watch(fieldOccurrenceId, (newVal, oldVal) => {
  if (newVal !== oldVal) {
    setParam('/tasks/field_occurrences/new_field_occurrences', {
      field_occurrence_id: newVal,
      collecting_event_id: undefined,
      otu_id: undefined
    })
  }
})

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('field_occurrence_id')
  const ceId = urlParams.get('collecting_event_id')

  if (/^\d+$/.test(id)) {
    loadForms(id)
  }

  if (ceId) {
    ceStore.load(ceId)
  }
})

async function loadForms(id) {
  const args = {
    objectId: id,
    objectType: FIELD_OCCURRENCE
  }

  settings.isLoading = true

  foStore.load(id).then(async ({ body }) => {
    const ceId = body.collecting_event_id

    if (ceId) {
      await ceStore.load(ceId)
    }
  })

  const requests = [
    originRelationshipStore.load(args),
    determinationStore.load(args),
    biocurationStore.load(args),
    citationStore.load(args),
    biologicalAssociationStore.load(args),
    depictionStore.load(args)
  ]

  Promise.all(requests).then(() => {
    settings.isLoading = false
  })
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
  },
  {
    keys: [platformKey(), 'l'],
    preventDefault: true,
    handler() {
      settings.toggleLock()
    }
  },
  {
    keys: [platformKey(), 'f'],
    preventDefault: true,
    handler() {
      autocompleteRef.value?.open()
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

TW.workbench.keyboard.createLegend(
  `${platformKey()}+l`,
  'Lock/Unlock all',
  'New field occurrence'
)

TW.workbench.keyboard.createLegend(
  `${platformKey()}+f`,
  'Search a field occurrence',
  'New field occurrence'
)
</script>
