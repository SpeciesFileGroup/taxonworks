<template>
  <div id="new_collecting_event_task">
    <VSpinner
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isSaving || isLoading"
    />
    <div class="flex-separate middle">
      <h1>{{ store.collectingEvent.id ? 'Edit' : 'New' }} collecting event</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="sortable"
            />
            Reorder fields
          </label>
        </li>
        <li>
          <autocomplete
            url="/collecting_events/autocomplete"
            class="autocomplete-search-bar"
            param="term"
            label="label_html"
            :clear-after="true"
            placeholder="Search a collecting event"
            @get-item="(e) => loadCollectingEvent(e.id)"
          />
        </li>
        <li>
          <RecentComponent @select="(e) => loadCollectingEvent(e.id)" />
        </li>
      </ul>
    </div>
    <NavBar>
      <div class="flex-separate full_width">
        <div class="middle margin-small-left">
          <span
            v-if="store.collectingEvent.id"
            class="margin-small-left"
            v-html="store.collectingEvent.object_tag"
          />
          <span
            class="margin-small-left"
            v-else
          >
            New record
          </span>
          <div
            v-if="store.collectingEvent.id"
            class="horizontal-left-content margin-small-left gap-small"
          >
            <pin-component
              class="circle-button"
              :object-id="store.collectingEvent.id"
              :type="COLLECTING_EVENT"
            />
            <radial-annotator :global-id="store.collectingEvent.global_id" />
            <radial-object :global-id="store.collectingEvent.global_id" />
          </div>
        </div>
        <ul class="context-menu no_bullets">
          <li class="horizontal-right-content gap-small">
            <span
              v-if="store.isUnsaved"
              class="medium-icon"
              title="You have unsaved changes."
              data-icon="warning"
            />
            <navigate-component
              :collecting-event="store.collectingEvent"
              @select="(e) => loadCollectingEvent(e.id)"
            />
            <CloneForm
              :disabled="!store.collectingEvent.id"
              @clone="(e) => loadCollectingEvent(e.id)"
            />
            <button
              type="button"
              class="button normal-input button-submit button-size"
              @click="saveCollectingEvent"
            >
              Save
            </button>
            <button
              type="button"
              class="button normal-input button-default button-size"
              @click="reset"
            >
              New
            </button>
          </li>
        </ul>
      </div>
      <ConfirmationModal ref="confirmationModal" />
    </NavBar>

    <div class="horizontal-left-content align-start gap-medium">
      <FormCollectingEvent
        :sortable="sortable"
        class="full_width panel content"
      />
      <div>
        <div class="panel content">
          <h3>Collection object</h3>
          <div class="horizontal-left-content">
            <button
              type="button"
              class="button normal-input button-default margin-small-right"
              @click="openComprehensive"
              :disabled="!store.collectingEvent.id"
            >
              New
            </button>
            <CollectionObjectsTable
              class="margin-small-right"
              :ce-id="store.collectingEvent.id"
            />
            <ParseData @parse="setParsedData" />
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
import Autocomplete from '@/components/ui/Autocomplete'
import FormCollectingEvent from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import useStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import RecentComponent from './components/Recent'

import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import platformKey from '@/helpers/getPlatformKey'
import SetParam from '@/helpers/setParam'

import PinComponent from '@/components/ui/Button/ButtonPin.vue'
import RightSection from './components/RightSection'
import NavBar from '@/components/layout/NavBar'
import ParseData from './components/parseData'
import CloneForm from './components/CloneForm.vue'

import CollectionObjectsTable from './components/CollectionObjectsTable.vue'
import NavigateComponent from './components/Navigate'
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

const hotkeys = ref([
  {
    keys: [platformKey(), 's'],
    preventDefault: true,
    handler() {
      store.save()
    }
  },
  {
    keys: [platformKey(), 'n'],
    preventDefault: true,
    handler() {
      reset()
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

store.$onAction(({ name, after }) => {
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
    store.save()
  }
}

function openComprehensive() {
  window.open(
    `${RouteNames.DigitizeTask}?collecting_event_id=${store.collectingEvent.id}`,
    '_self'
  )
}
</script>
<style lang="scss">
#new_collecting_event_task {
  .button-size {
    width: 100px;
  }

  .autocomplete-search-bar {
    input {
      width: 500px;
    }
  }
}
</style>
