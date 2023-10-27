<template>
  <v-btn
    :disabled="!getDefault"
    circle
    color="primary"
    :title="buttonTitle"
    @click="sendDefault"
  >
    <v-icon
      small
      color="white"
      name="pin"
      :title="buttonTitle"
    />
  </v-btn>
</template>
<script>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

export default {
  components: {
    VBtn,
    VIcon
  },

  props: {
    section: {
      type: String,
      required: true
    },

    label: {
      type: String,
      default: ''
    },

    type: {
      type: String,
      required: true
    }
  },

  computed: {
    buttonTitle() {
      return this.getDefault
        ? `Use [${this.getLabel}]`
        : `Make default ${this.type} from pinboard to use it`
    }
  },

  emits: ['getId', 'getLabel', 'getItem'],

  data() {
    return {
      getDefault: undefined,
      getLabel: undefined
    }
  },

  mounted() {
    this.checkForDefault()
    document.addEventListener('pinboard:insert', this.handleEvent)
  },

  unmounted() {
    document.removeEventListener('pinboard:insert', this.handleEvent)
  },

  methods: {
    sendDefault() {
      if (this.getDefault) {
        this.$emit('getId', this.getDefault)
      }
      if (this.getLabel) {
        this.$emit('getLabel', this.getLabel)
      }
      if (this.getLabel && this.getDefault) {
        this.$emit('getItem', { id: this.getDefault, label: this.getLabel })
      }
    },

    checkForDefault() {
      const defaultElement = document.querySelector(
        `[data-pinboard-section="${this.section}"] [data-insert="true"]`
      )

      this.getDefault = defaultElement?.dataset?.pinboardObjectId
      this.getLabel = defaultElement?.querySelector('a')?.textContent
    },

    handleEvent(event) {
      if (event.detail.type === this.type) {
        this.checkForDefault()
      }
    }
  }
}
</script>
