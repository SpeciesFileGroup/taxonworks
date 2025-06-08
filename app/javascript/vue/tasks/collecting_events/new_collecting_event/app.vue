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
          <VAutocomplete
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
        <ul class="context-menu no_bullets">
          <li class="horizontal-right-content gap-small">
            <span
              v-if="store.isUnsaved"
              class="medium-icon"
              title="You have unsaved changes."
              data-icon="warning"
            />
            <VNavigate
              :collecting-event="store.collectingEvent"
              @select="(e) => loadCollectingEvent(e.id)"
            />
            <CloneForm
              :disabled="!store.collectingEvent.id"
              @clone="(e) => loadCollectingEvent(e.id)"
            />
            <VBtn
              color="primary"
              medium
              class="button-size"
              @click="saveCollectingEvent"
            >
              Save
            </VBtn>
            <VBtn
              color="primary"
              medium
              class="button-size"
              @click="reset"
            >
              New
            </VBtn>
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
          <div class="horizontal-left-content gap-small">
            <VBtn
              color="primary"
              medium
              :disabled="!store.collectingEvent.id"
              @click="openComprehensive"
            >
              New
            </VBtn>
            <ModalCollectionObjects :ce-id="store.collectingEvent.id" />
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
import { smartSelectorRefresh } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import VAutocomplete from '@/components/ui/Autocomplete'
import FormCollectingEvent from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import useStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import RecentComponent from './components/Recent'

import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import platformKey from '@/helpers/getPlatformKey'
import SetParam from '@/helpers/setParam'

import VPin from '@/components/ui/Button/ButtonPin.vue'
import RightSection from './components/RightSection'
import NavBar from '@/components/layout/NavBar'
import ParseData from './components/parseData'
import CloneForm from './components/CloneForm.vue'

import ModalCollectionObjects from './components/ModalCollectionObjects/ModalCollectionObjects.vue'
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
    store
      .save()
      .then(() => {
        SetParam(
          RouteNames.NewCollectingEvent,
          'collecting_event_id',
          store.collectingEvent.id
        )
        smartSelectorRefresh()
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
