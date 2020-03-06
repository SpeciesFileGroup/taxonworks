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
        <table class="full_width">
          <thead>
            <tr>
              <th>CO Propierties</th>
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
              v-for="(key, index) in Object.keys(compare[0])"
              :key="key"
              class="contextMenuCells"
              :class="{ even: index % 2 }">
              <td>{{ key }}</td>
              <td v-html="compare[0][key]"/>
              <td v-html="compare[1][key]"/>
            </tr>
          </tbody>
        </table>
        <table class="full_width">
          <thead>
            <tr>
              <th>CE Propierties</th>
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

import ModalComponent from 'components/modal'
import { GetCollectingEvent } from '../request/resources'
export default {
  components: {
    ModalComponent
  },
  props: {
    compare: {
      type: Array,
      default: () => { return [] }
    }
  },
  data () {
    return {
      showModal: false,
      compareCE: [],
      ceProperties: []
    }
  },
  watch: {
    showModal(newVal) {
      if (newVal)
        this.getCEs()
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
        GetCollectingEvent(ceId).then(response => {
          this.compareCE[1] = response.body
          this.ceProperties = Object.keys(response.body)
        })
    }
  }
}
</script>
<style scoped>

/deep/ .modal-container {
  width: 1024px;
  overflow-y: scroll;
  max-height: 80vh;
}

</style>