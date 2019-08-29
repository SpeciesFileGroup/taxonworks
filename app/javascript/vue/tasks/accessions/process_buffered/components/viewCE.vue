<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="show = true">
      Show
    </button>
    <modal 
      v-if="show"
      class="full_width"
      @close="show = false">
      <h3 slot="header">Collecting events details</h3>
      <div slot="body">
        <table class="full_width">
          <tr
            v-for="(value, key, index) in collectingEvent"
            :key="key"
            :class="{ even: index % 2 }"
            class="contextMenuCells">
            <td>{{ key }}</td>
            <td>
              <b>
                <span v-html="value"/>
              </b>
            </td>
          </tr>
        </table>
      </div>
    </modal>
  </div>
</template>

<script>

import Modal from 'components/modal'

export default {
  components: {
    Modal
  },
  props: {
    collectingEvent: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      show: false
    }
  }

}
</script>

<style lang="scss" scoped>
  /deep/ .modal-container {
    width: 600px !important;
    height: 80vh;
    overflow-y: scroll;
  }
</style>