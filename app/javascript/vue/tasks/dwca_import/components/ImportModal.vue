<template>
  <div>
    <button
      @click="setModalView(true)"
      :disabled="disableStatus.includes(dataset.status)"
      class="button normal-input button-default">
      Import
    </button>
    <modal-component
      v-if="showModal"
      @close-x="stopImport(); setModalView(false)"
      @close-esc="stopImport(); setModalView(false)"
      :container-style="{
        width: '700px'
      }">
      <h3 slot="header">Import dataset</h3>
      <div slot="body">
        <transition name="bounce">
          <div
            v-if="settings.isProcessing"
            style="height: 200px">
            <spinner-component
              legend="Importing rows... please wait."
            />
          </div>
        </transition>
        <progress-bar :progress="dataset.progress"/>
        <progress-list
          class="no_bullets context-menu"
          :progress="dataset.progress"/>
      </div>
      <template slot="footer">
        <button
          v-if="settings.isProcessing"
          type="button"
          :disabled="settings.stopRequested"
          class="button normal-input button-default margin-medium-top"
          @click="stopImport">
          Stop import
        </button>
        <button
          v-else
          type="button"
          class="button normal-input button-submit"
          @click="startImport">
          Start import
        </button>
        <input
          type="checkbox"
          v-model="settings.retryErrored"> Retry errored records
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import ProgressBar from './ProgressBar'
import ProgressList from './ProgressList'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import { disableStatus } from '../const/datasetStatus'

export default {
  components: {
    SpinnerComponent,
    ModalComponent,
    ProgressBar,
    ProgressList
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    dataset () {
      return this.$store.getters[GetterNames.GetDataset]
    }
  },
  data () {
    return {
      showModal: false,
      disableStatus: Object.keys(disableStatus)
    }
  },
  methods: {
    setModalView (value) {
      this.showModal = value
    },
    startImport (value) {
      this.$store.dispatch(ActionNames.ProcessImport)
    },
    stopImport () {
      this.$store.dispatch(ActionNames.StopImport)
    }
  }
}
</script>
