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
    let that = this
    document.addEventListener('pinboard:remove', function(event) {
      if(that.pin.id == event.detail.id) {
        that.pin = undefined
      }
    })
  },
  methods: {
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
