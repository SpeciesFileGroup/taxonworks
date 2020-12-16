<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="setModalView(true)"
      :disabled="!collectingEvent.id">
      Navigate
    </button>
    <modal-component
      v-if="showModal"
      @close="showModalView(false)">
      <h3 slot="header">Navigate</h3>
      <div slot="body">
        <spinner-component v-if="isLoading"/>
        <table>
          <thead>
            <tr>
              <th>Previous</th>
              <th>Next</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="key in Object.keys(navigate.previous_by || navigate.next_by)"
              :key="key">
              <td>
                <button
                  type="button"
                  :disabled="!navigate.previous_by[key]">
                  {{ key.replaceAll('_', '') }}
                </button>
              </td>
              <td>
                <button
                  type="button"
                  :disabled="!navigate.next_by[key]"
                  @click="loadCE(navigate.next_by[key])">
                  {{ key.replaceAll('_', '') }}
                </button>
              </td>
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
import { NavigateCollectingEvents } from '../request/resources'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },
  props: {
    collectingEvent: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      isLoading: false,
      navigate: undefined,
      showModal: false
    }
  },
  watch: {
    showModal (newVal) {
      if (newVal && this.collectingEvent.id) {
        this.isLoading = true
        NavigateCollectingEvents(this.collectingEvent.id).then(response => {
          this.navigate = response.body
        }).finally(() => {
          this.isLoading = false
        })
      }
    }
  },
  methods: {
    setModalView(value) {
      this.showModal = value
    },
    loadCE(id) {
      this.$emit('select', id)
    }
  }
}
</script>
