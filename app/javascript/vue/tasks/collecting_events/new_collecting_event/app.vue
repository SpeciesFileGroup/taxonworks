<template>
  <div id="new_collecting_event_task">
    <VSpinner
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isSaving || isLoading"
    />
    <NavBar navbar-class="panel content rounded-tl-none rounded-tr-none">
      <div class="flex-separate full_width">
        <div class="horizontal-left-content middle gap-medium">
          <AutocompletePopover
            ref="autocomplete"
            url="/collecting_events/autocomplete"
            param="term"
            label="label_html"
            placeholder="Search"
            panel-width="400px"
            min="1"
            medium
            clear-after
            title="Search a collecting event"
            @select="(e) => loadCollectingEvent(e.id)"
          />
          <div class="horizontal-left-content middle gap-small">
            <span
              v-if="store.collectingEvent.id"
              v-html="store.collectingEvent.object_tag"
            />
            <span v-else> New record </span>
            <div
              v-if="store.collectingEvent.id"
              class="horizontal-left-content gap-small"
            >
              <VPin
                :object-id="store.collectingEvent.id"
                :type="COLLECTING_EVENT"
              />
              <RadialAnnotator :global-id="store.collectingEvent.global_id" />
              <RadialObject :global-id="store.collectingEvent.global_id" />
            </div>
          </div>
        </div>
        <div class="horizontal-right-content middle gap-small">
          <IconWarning
            v-if="store.isUnsaved"
            class="w-4 h-4 text-attention-color"
            v-tooltip="'You have unsaved changes.'"
          />
          <VBtn
            color="create"
            medium
            class="button-size"
            @click="saveCollectingEvent"
          >
            Save
          </VBtn>
          <CloneForm
            medium
            variant="tonal"
            :disabled="!store.collectingEvent.id"
            @clone="(e) => loadCollectingEvent(e.id)"
          />
          <VBtn
            color="primary"
            medium
            variant="tonal"
            class="button-size"
            @click="reset"
          >
            New
          </VBtn>
          <VNavigate
            :collecting-event="store.collectingEvent"
            @select="(e) => loadCollectingEvent(e.id)"
          />
          <RecentComponent @select="(e) => loadCollectingEvent(e.id)" />
          <SettingsModal v-model:sortable="sortable" />
        </div>
      </div>
      <ConfirmationModal ref="confirmationModal" />
    </NavBar>

    <div class="horizontal-left-content align-start gap-medium">
      <FormCollectingEvent
        :sortable="sortable"
        class="full_width panel content"
      />
      <div class="flex-col gap-medium">
        <div class="panel content">
          <h3>Collection object</h3>
          <div class="horizontal-left-content gap-small">
            <ModalCollectionObjects :ce-id="store.collectingEvent.id" />
            <VBtn
              color="primary"
              medium
              variant="tonal"
              :disabled="!store.collectingEvent.id"
              @click="openComprehensive"
            >
              New
            </VBtn>
            <ParseData @parse="setParsedData" />
          </div>
        </div>
        <div class="panel content">
          <h3>Field occurrence</h3>
          <div class="horizontal-left-content gap-small">
            <ModalFieldOccurrences :ce-id="store.collectingEvent.id" />
            <VBtn
              color="primary"
              medium
              variant="tonal"
              :disabled="!store.collectingEvent.id"
              @click="openNewFieldOccurrence"
            >
              New
            </VBtn>
          </div>
        </div>
        <RightSection @select="(e) => loadCollectingEvent(e.id)" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, useTemplateRef } from 'vue'
import { RouteNames } from '@/routes/routes'
import { useHotkey } from '@/composables'
import { smartSelectorRefresh } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import AutocompletePopover from '@/components/ui/Autocomplete/AutocompletePopover.vue'
import FormCollectingEvent from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import useStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import RecentComponent from './components/Recent'

import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import platformKey from '@/helpers/getPlatformKey'
import SetParam from '@/helpers/setParam'

import IconWarning from '@/components/Icon/IconWarning.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import RightSection from './components/RightSection'
import NavBar from '@/components/layout/NavBar'
import ParseData from './components/parseData'
import CloneForm from './components/CloneForm.vue'
import SettingsModal from './components/SettingsModal.vue'

import ModalCollectionObjects from './components/ModalCollectionObjects/ModalCollectionObjects.vue'
import ModalFieldOccurrences from './components/ModalFieldOccurrences/ModalFieldOccurrences.vue'
import VNavigate from './components/Navigate'
import VSpinner from '@/components/ui/VSpinner'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

import { CollectionObject } from '@/routes/endpoints'
import { getTotalCOByCEId } from './helpers/getTotalCO.js'
import { COLLECTING_EVENT } from '@/constants'

const MAX_CO_LIMIT = 100

defineOptions({
  name: 'NewCollectingEvent'
})

const store = useStore()
const autocompleteRef = useTemplateRef('autocomplete')

const hotkeys = ref([
  {
    keys: [platformKey(), 's'],
    preventDefault: true,
    handler() {
      saveCollectingEvent()
    }
  },
  {
    keys: [platformKey(), 'n'],
    preventDefault: true,
    handler() {
      reset()
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

const totalCO = ref(0)

useHotkey(hotkeys.value)

watch(
  () => store.collectingEvent.id,
  async (newVal) => {
    if (newVal) {
      totalCO.value = newVal ? await getTotalCOByCEId(newVal) : 0
    }
  }
)

const isLoading = ref(false)
const isSaving = ref(false)

const sortable = ref(false)
const confirmationModal = useTemplateRef('confirmationModal')

store.$onAction(({ name, after, onError }) => {
  switch (name) {
    case 'load':
      isLoading.value = true
      break
    case 'save':
      isSaving.value = true
      break
  }

  after(() => {
    switch (name) {
      case 'load':
        isLoading.value = false
        break
      case 'save':
        isSaving.value = false
        break
    }
  })

  onError(() => {
    isSaving.value = false
    isLoading.value = false
  })
})

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const collectingEventId = urlParams.get('collecting_event_id')
  const collectionObjectId = urlParams.get('collection_object_id')

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save',
    'New collecting event'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+n`,
    'New',
    'New collecting event'
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+f`,
    'Search a collecting event',
    'New collecting event'
  )

  if (/^\d+$/.test(collectingEventId)) {
    store.load(collectingEventId)
  } else if (/^\d+$/.test(collectionObjectId)) {
    CollectionObject.find(collectionObjectId).then(({ body }) => {
      const ceId = body.collecting_event_id

      if (ceId) {
        loadCollectingEvent(ceId)
      }
    })
  }
})

function reset() {
  store.reset()
  SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id')
  SetParam(RouteNames.NewCollectingEvent, 'collection_object_id')
}

function loadCollectingEvent(ceId) {
  store.load(ceId)
  SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', ceId)
}

function setParsedData(data) {
  store.collectingEvent = {
    ...store.collectingEvent,
    ...data,
    isUnsaved: true
  }
}

async function saveCollectingEvent() {
  const underThreshold = totalCO.value < MAX_CO_LIMIT

  const ok =
    underThreshold ||
    (await confirmationModal.value.show({
      title: 'Save collecting event',
      message: `This collecting event is used for ${totalCO.value} collection objects. Are you sure you want to proceed?`,
      confirmationWord: 'SAVE',
      okButton: 'Save',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    }))

  if (ok) {
    store
      .save()
      .then(() => {
        SetParam(
          RouteNames.NewCollectingEvent,
          'collecting_event_id',
          store.collectingEvent.id
        )
        smartSelectorRefresh()

        TW.workbench.alert.create(
          'Collecting event was successfully saved.',
          'notice'
        )
      })
      .catch(() => {})
  }
}

function openComprehensive() {
  window.open(
    `${RouteNames.DigitizeTask}?collecting_event_id=${store.collectingEvent.id}`,
    '_self'
  )
}

function openNewFieldOccurrence() {
  window.open(
    `${RouteNames.NewFieldOccurrence}?collecting_event_id=${store.collectingEvent.id}`,
    '_self'
  )
}
</script>
