<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="setModalView(true)">Parse from
    </button>
    <modal-component
      v-if="showModal"
      @close="setModalView(false)"
      :container-style="{ width: '800px' }">
      <template #header>
        <h3>Parse collection object buffered data</h3>
      </template>
      <template #body>
        <smart-selector
          model="collection_objects"
          target="CollectingEvent"
          @selected="parseData"
        />
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import SmartSelector from 'components/ui/SmartSelector'
import { CollectingEvent } from 'routes/endpoints'

export default {
  components: {
    ModalComponent,
    SmartSelector
  },

  data () {
    return {
      collectionObject: undefined,
      parsableData: undefined,
      showModal: false
    }
  },

  emits: ['onParse'],

  methods: {
    setCollectionObject (co) {
      this.collectionObject = co
    },

    parseData (co) {
      CollectingEvent.parseVerbatimLabel({ verbatim_label: co.buffered_collecting_event }).then(response => {
        if (response.body) {
          this.parsableData = response.body

          this.$emit('onParse', Object.assign({},
            this.parsableData.date,
            this.parsableData.geo.verbatim,
            this.parsableData.elevation,
            this.parsableData.collecting_method))
          TW.workbench.alert.create('Buffered value parsed.', 'notice')
          this.setModalView(false)
        } else {
          TW.workbench.alert.create('No buffered value to convert.', 'error')
        }
      })
    },

    setModalView (value) {
      this.showModal = value
    }
  }
}
</script>
