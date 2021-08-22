<template>
  <div>
    <spinner-component
      v-if="searching"
      :show-legend="false"
      :logo-size="{
        width: '14px',
        height: '14px'
      }"/>
    <button
      type="button"
      class="button normal-input button-default"
      @click="cloneLabel"
      :disabled="!bufferedCollectingEvent">
      Clone from specimen
    </button>
    <modal-component
      v-if="showModal"
      @close="closeModal">
      <template #header>
        <h3>Existing collecting events</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="ce in list"
            :key="ce.id"
            class="separate-bottom">
            <label
              @click="selectedCE = ce">
              <input
                type="radio"
                name="modal-ce">
              <span v-html="ce.object_tag"/>
            </label>
          </li>
          <button
            type="button"
            :disabled="!selectedCE"
            @click="setCE(selectedCE)"
            class="button normal-input button-default">
            Set collecting event
          </button>
        </ul>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import { CollectingEvent } from 'routes/endpoints'
import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: {
    ModalComponent,
    SpinnerComponent
  },

  computed: {
    bufferedCollectingEvent () {
      return this.$store.getters[GetterNames.GetCollectionObject].buffered_collecting_event
    },

    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    }
  },

  data () {
    return {
      selectedCE: undefined,
      showModal: false,
      searching: false,
      list: []
    }
  },

  watch: {
    searching (newVal) {
      if (!newVal && this.list.length) {
        this.showModal = true
      } else {
        this.collectingEvent.verbatim_label = this.bufferedCollectingEvent
      }
    }
  },

  methods: {
    cloneLabel () {
      this.searching = true
      CollectingEvent.where({ verbatim_label: this.bufferedCollectingEvent }).then(response => {
        this.list = response.body
        this.searching = false
        CollectingEvent.parseVerbatimLabel({ verbatim_label: this.bufferedCollectingEvent }).then(response => {
          const parsed = response.body

          this.collectingEvent = Object.assign(
            this.collectingEvent,
            parsed.date,
            parsed.geo.verbatim,
            parsed.elevation,
            parsed.collecting_method
          )
        })
      })
    },

    setCE (ce) {
      this.collectingEvent = ce
      this.closeModal()
    },

    closeModal () {
      this.showModal = false
      this.selectedCE = false
    }
  }
}
</script>
