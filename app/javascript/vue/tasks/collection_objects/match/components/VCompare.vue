<template>
  <div>
    <button
      class="button button-default normal-input"
      type="button"
      @click="showModal = true"
      :disabled="!compare.length"
    >
      Compare
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false"
    >
      <template #header>
        <h3>Compare collection objects</h3>
      </template>
      <template #body>
        <switch-component
          v-model="view"
          :options="tabs"
        />
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th>CO Properties</th>
              <th
                v-for="item in compare"
                :key="item.id"
              >
                <span v-html="item.object_tag" />
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="key in Object.keys(renderType[0])"
              :key="key"
              class="contextMenuCells"
            >
              <td>{{ key }}</td>
              <td
                v-for="(item, index) in compare"
                :key="item.id"
                v-html="renderType[index][key]"
              />
            </tr>
            <tr />
          </tbody>
          <thead>
            <tr>
              <th>CE attributes</th>
              <th
                v-for="ce in compareCE"
                :key="ce.id"
              >
                <span
                  v-if="ce.id"
                  v-html="ce.object_tag"
                />
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="key in ceAttributes"
              :key="key"
              class="contextMenuCells"
            >
              <td>{{ key }}</td>
              <td
                v-for="ce in compareCE"
                :key="ce.id"
                v-html="ce[key] || ''"
              />
            </tr>
          </tbody>
        </table>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import ModalComponent from '@/components/ui/Modal'
import SwitchComponent from '@/components/ui/VSwitch'
import { CollectingEvent, CollectionObject } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'

const TABS_TYPE = {
  DETAILS: 'details',
  DWC: 'DWC'
}

const props = defineProps({
  compare: {
    type: Array,
    default: () => []
  }
})

const renderType = computed(() =>
  view.value === TABS_TYPE.DWC ? dwcTable.value : props.compare
)

const showModal = ref(false)
const compareCE = ref([])
const ceAttributes = ref([])
const tabs = Object.values(TABS_TYPE)
const view = ref(TABS_TYPE.DETAILS)
const dwcTable = ref({})

function getCEs() {
  const requests = props.compare.map((co) =>
    co.collecting_event_id
      ? CollectingEvent.find(co.collecting_event_id)
      : Promise.resolve({ body: {} })
  )

  Promise.all(requests).then((responses) => {
    const collectingEvents = responses.map((r) => r.body)

    compareCE.value = collectingEvents
    ceAttributes.value = Object.keys(collectingEvents.find((ce) => ce.id) || {})
  })
}

function loadDWC() {
  const requests = props.compare.map((co) =>
    CollectionObject.dwcVerbose(co.id, { rebuild: true })
  )

  Promise.all(requests).then((responses) => {
    dwcTable.value = responses.map((r) => r.body)
  })
}

watch(showModal, (newVal) => {
  if (newVal) {
    loadDWC()
    getCEs()
  }
})
</script>
<style scoped>
:deep(.modal-container) {
  width: 80vw;
  overflow-y: scroll;
  max-height: 80vh;
}
</style>
