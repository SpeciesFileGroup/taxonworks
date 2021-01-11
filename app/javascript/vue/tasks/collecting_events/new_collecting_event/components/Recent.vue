<template>
  <div>
    <spinner-component
      :full-screen="true"
      v-if="isLoading"/>
    <button
      @click="showModalView(true)"
      class="button normal-input button-default button-size separate-left"
      type="button">
      Recent
    </button>
    <modal-component
      :container-style="{ width: '800px' }"
      @close="showModalView(false)">
      <h3 slot="header">Recent collecting events</h3>
      <div slot="body">
        <table class="full_width">
          <thead>
            <tr>
              <th>Object tag</th>
              <th/>
            </tr>
          </thead>
          <tbody>
            <tr
              class="contextMenuCells"
              v-for="(item, index) in collectingEvents"
              :key="item.id">
              <td v-html="item.object_tag"/>
              <td>
                <div class="horizontal-left-content">
                  <span
                    class="button circle-button btn-edit"
                    @click="selectCollectingEvent(item)"/>
                  <span
                    class="button circle-button btn-delete button-delete"
                    @click="removeCollectingEvent(index)"/>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { GetCollectingEvents, DestroyCollectingEvent } from '../request/resources'
import SpinnerComponent from 'components/spinner'
import ModalComponent from 'components/modal'

export default {
  components: {
    SpinnerComponent,
    ModalComponent
  },
  data () {
    return {
      collectingEvents: [],
      isLoading: false,
      showModal: false
    }
  },
  mounted () {
    this.isLoading = true
    GetCollectingEvents({ per: 10, recent: true }).then(response => {
      this.collectingEvents = response.body
    }).finally(() => {
      this.isLoading = false
    })
  },
  methods: {
    showModalView (value) {
      this.$emit('close', value)
    },
    removeCollectingEvent (index) {
      if (window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        DestroyCollectingEvent(this.collectingEvents[index].id).then(response => {
          this.collectingEvents.splice(index, 1)
        })
      }
    },
    selectCollectingEvent (collectingEvent) {
      this.$emit('select', collectingEvent)
      this.showModalView(false)
    }
  }
}
</script>
