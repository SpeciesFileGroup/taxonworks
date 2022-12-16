<template>
  <div>
    <button
      class="button button-default normal-input"
      type="button"
      @click="showModal = true"
      :disabled="!compare.length">
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
              v-for="(key) in Object.keys(renderType[0])"
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

<script>

import ModalComponent from 'components/ui/Modal'
import SwitchComponent from 'components/switch'

import { GetDWC } from '../request/resources'
import { CollectingEvent } from 'routes/endpoints'

const TABS_TYPE = {
  DETAILS: 'details',
  DWC: 'DWC'
}

export default {
  components: {
    ModalComponent,
    SwitchComponent
  },

  props: {
    compare: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    renderType () {
      return this.view === TABS_TYPE.DWC
        ? this.dwcTable
        : this.compare
    }
  },

  data () {
    return {
      showModal: false,
      compareCE: [],
      ceAttributes: [],
      tabs: Object.values(TABS_TYPE),
      view: TABS_TYPE.DETAILS,
      dwcTable: {}
    }
  },

  watch: {
    showModal (newVal) {
      if (newVal) {
        this.LoadDWC()
        this.getCEs()
      }
    }
  },

  methods: {
    getCEs () {
      const requests = this.compare.map(
        co => co.collecting_event_id
          ? CollectingEvent.find(co.collecting_event_id)
          : Promise.resolve({ body: {} })
      )

      Promise.all(requests).then(responses => {
        const collectingEvents = responses.map(r => r.body)
        console.log(collectingEvents)

        this.compareCE = collectingEvents
        this.ceAttributes = Object.keys(collectingEvents.find(ce => ce.id) || {})
      })
    },

    LoadDWC () {
      const requests = this.compare.map(co => GetDWC(co.id))

      Promise.all(requests).then(responses => {
        this.dwcTable = responses.map(r => r.body)
      })
    }
  }
}
</script>
<style scoped>

:deep(.modal-container) {
  width: 80vw;
  overflow-y: scroll;
  max-height: 80vh;
}

</style>
