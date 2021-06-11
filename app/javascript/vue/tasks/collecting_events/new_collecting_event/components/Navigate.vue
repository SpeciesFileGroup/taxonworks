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
      @close="setModalView(false)"
      :containerStyle="{ width: '500px'}">
      <h3 slot="header">Navigate</h3>
      <div slot="body">
        <p>Current: <span v-html="collectingEvent.object_tag"/></p>
        <spinner-component v-if="isLoading"/>
        <table class="full_width">
          <thead>
            <tr>
              <th>Previous by</th>
              <th>Next by</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="key in Object.keys(navigate.previous_by || navigate.next_by)"
              :key="key">
              <td>
                <button
                  type="button"
                  class="button normal-input button-default"
                  :disabled="!navigate.previous_by[key]"
                  @click="loadCE(navigate.previous_by[key])">
                  {{ key.replaceAll('_', ' ') }}
                </button>
              </td>
              <td>
                <button
                  class="button normal-input button-default"
                  type="button"
                  :disabled="!navigate.next_by[key]"
                  @click="loadCE(navigate.next_by[key])">
                  {{ key.replaceAll('_', ' ') }}
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

import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import { CollectingEvent } from 'routes/endpoints'

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

  emits: ['select'],

  computed: {
    collectingEventId () {
      return this.collectingEvent.id
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
    collectingEventId (newVal) {
      if (newVal) {
        this.isLoading = true
        CollectingEvent.navigation(this.collectingEvent.id).then(response => {
          this.navigate = response.body
        }).finally(() => {
          this.isLoading = false
        })
      }
    }
  },

  methods: {
    setModalView (value) {
      this.showModal = value
    },

    loadCE (id) {
      this.$emit('select', id)
    }
  }
}
</script>
