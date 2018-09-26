<template>
  <div
    v-if="!pin"
    class="pin-button"
    @click="createPin()"/>
  <div
    v-else
    class="unpin-button"
    @click="deletePin()"/>
</template>

<script>
export default {
  props: {
    pinObject: {
      type: Object,
      default: undefined
    },
    objectId: {
      type: [String, Number],
      required: true,
    },
    type: {
      type: String,
      required: true
    }
  },
  data: function () {
    return {
      pin: this.pinObject,
      id: this.objectId
    }
  },
  watch: {
    pinObject: function (newVal) {
      this.pin = newVal
    },
    objectId: function (newVal) {
      this.id = newVal
    }
  },
  mounted() {
    document.addEventListener('pinboard:remove', this.clearPin)
  },
  destroyed() {
    document.removeEventListener('pinboard:remove', this.clearPin)
  },
  methods: {
    clearPin: function (event) {
      if(this.pin && this.pin.id == event.detail.id) {
        this.pin = undefined
      }
    },
    createPin: function () {
      let pinItem = {
        pinboard_item: {
          pinned_object_id: this.id,
          pinned_object_type: this.type
        }
      }
      this.$http.post('/pinboard_items', pinItem).then(response => {
        this.pin = response.body
        TW.workbench.pinboard.addToPinboard(response.body)
        TW.workbench.alert.create('Pinboard item was successfully created.', 'notice')
      })
    },
    deletePin: function () {
      this.$http.delete(`/pinboard_items/${this.pin.id}`, { _destroy: true }).then(response => {
        TW.workbench.pinboard.removeItem(this.pin.id)
        this.pin = undefined
        TW.workbench.alert.create('Pinboard item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>
