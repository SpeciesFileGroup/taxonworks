<template>
  <div>
    <button
      class="button button-default"
      type="button"
      @click="showModal = true"
      :disabled="!compare.length">
      Compare
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Compare collection objects</h3>
      <div slot="body">
        <switch-component
          v-model="view"
          :options="tabs"
        />
        <table class="full_width">
          <thead>
            <tr>
              <th>CO Properties</th>
              <th>
                <span v-html="compare[0].object_tag"/>
              </th>
              <th>
                <span v-html="compare[1].object_tag"/>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(key, index) in Object.keys(renderType[0])"
              :key="key"
              class="contextMenuCells"
              :class="{ even: index % 2 }">
              <td>{{ key }}</td>
              <td v-html="renderType[0][key]"/>
              <td v-html="renderType[1][key]"/>
            </tr>
            <tr></tr>
          </tbody>
          <thead>
            <tr>
              <th>CE Properties</th>
              <th>
                <span 
                  v-if="compareCE[0]"
                  v-html="compareCE[0].object_tag"/>
              </th>
              <th>
                <span
                  v-if="compareCE[1]"
                  v-html="compareCE[1].object_tag"/>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(key, index) in ceProperties"
              :key="key"
              class="contextMenuCells"
              :class="{ even: index % 2 }">
              <td>{{ key }}</td>
              <td v-html="compareCE[0] ? compareCE[0][key] : ''"/>
              <td v-html="compareCE[1] ? compareCE[1][key] : ''"/>
            </tr>
          </tbody>
        </table>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import SwitchComponent from 'components/switch'

import { GetCollectingEvent, GetDWC } from '../request/resources'

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
      default: () => { return [] }
    }
  },
  computed: {
    renderType() {
      return this.view === TABS_TYPE.DWC ? this.dwcTable : this.compare
    }
  },
  data () {
    return {
      showModal: false,
      compareCE: [],
      ceProperties: [],
      tabs: Object.values(TABS_TYPE),
      view: TABS_TYPE.DETAILS,
      dwcTable: {}
    }
  },
  watch: {
    showModal(newVal) {
      if (newVal) {
        this.LoadDWC()
        this.getCEs()
      }
    }
  },
  methods: {
    getCEs() {
      const ceId = this.compare[0]['collecting_event_id']
      const ceId2 = this.compare[1]['collecting_event_id']

      if(ceId)
        GetCollectingEvent(ceId).then(response => {
          this.compareCE[0] = response.body
          this.ceProperties = Object.keys(response.body)
        })
      if(ceId2)
        GetCollectingEvent(ceId2).then(response => {
          this.compareCE[1] = response.body
          this.ceProperties = Object.keys(response.body)
        })
    },
    LoadDWC () {
      GetDWC(this.compare[0].id).then(response => { this.$set(this.dwcTable, 0, response.body) })
      GetDWC(this.compare[1].id).then(response => { this.$set(this.dwcTable, 1, response.body) })
    }
  }
}
</script>
<style scoped>

:deep(.modal-container) {
  width: 1024px;
  overflow-y: scroll;
  max-height: 80vh;
}

</style>
