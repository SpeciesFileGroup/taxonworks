<template>
  <v-btn
    circle
    :color="pin ? 'destroy' : 'create'"
    @click="pin ? deletePin() : createPin()"
  >
    <v-icon
      small
      color="white"
      name="pin"
    />
  </v-btn>
</template>

<script>

import { PinboardItem } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    VBtn,
    VIcon
  },

  props: {
    pinObject: {
      type: Object,
      default: undefined
    },

    objectId: {
      type: [String, Number],
      required: true
    },

    type: {
      type: String,
      required: true
    },

    pluralize: {
      type: Boolean,
      default: true
    },

    section: {
      type: String,
      default: undefined
    }
  },

  data () {
    return {
      pin: this.pinObject,
      id: this.objectId
    }
  },

  watch: {
    pinObject (newVal) {
      this.pin = newVal
    },

    objectId (newVal) {
      this.id = newVal
      this.retrievePinnedObject()
    }
  },

  created () {
    this.retrievePinnedObject()
    document.addEventListener('pinboard:remove', this.clearPin)
  },

  unmounted () {
    document.removeEventListener('pinboard:remove', this.clearPin)
  },

  methods: {
    clearPin (event) {
      if (this.pin?.id === event.detail.id) {
        this.pin = undefined
      }
    },

    retrievePinnedObject () {
      const section = document.querySelector(`[data-pinboard-section="${this.section ? this.section : `${this.type}${this.pluralize ? 's' : ''}`}"] [data-pinboard-object-id="${this.id}"]`)

      this.pin = section
        ? {
            id: section.getAttribute('data-pinboard-item-id'),
            type: this.type
          }
        : undefined
    },

    createPin () {
      const pinboard_item = {
        pinned_object_id: this.id,
        pinned_object_type: this.type,
        is_inserted: true
      }

      PinboardItem.create({ pinboard_item }).then(({ body }) => {
        this.pin = body
        TW.workbench.pinboard.addToPinboard(body, true)
        TW.workbench.alert.create('Pinboard item was successfully created.', 'notice')
      })
    },

    deletePin () {
      PinboardItem.destroy(this.pin.id).then(() => {
        TW.workbench.pinboard.removeItem(this.pin.id)
        TW.workbench.alert.create('Pinboard item was successfully destroyed.', 'notice')
        this.pin = undefined
      })
    }
  }
}
</script>
