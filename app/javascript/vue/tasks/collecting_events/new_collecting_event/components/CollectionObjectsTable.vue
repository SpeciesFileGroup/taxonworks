<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      :disabled="!ceId"
      @click="showModal = true">Collection object attached</button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Collection objects attached to this collecting event</h3>
      <div slot="body">
        <spinner-component v-if="isLoading"/>
        <table class="full_width">
          <thead>
            <tr>
              <th>Collection object</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in list"
              :key="item.id"
              class="contextMenuCells"
              :class="{ 'even': (index % 2 == 0) }"
              @click="sendCO(item)">
              <td v-html="item.object_tag"/>
            </tr>
          </tbody>
        </table>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import { GetCollectionObjects } from '../request/resources.js'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },
  props: {
    ceId: {
      type: [Number, String],
      default: undefined
    }
  },
  data () {
    return {
      showModal: false,
      list: [],
      isLoading: false
    }
  },
  watch: {
    showModal (newVal) {
      if (newVal) {
        this.isLoading = true
        GetCollectionObjects({ collecting_event_ids: [this.ceId] }).then(response => {
          this.list = response.body
          this.isLoading = false
        })
      }
    }
  },
  methods: {
    sendCO (item) {
      this.showModal = false
      this.$emit('selected', item)
    }
  }
}
</script>
