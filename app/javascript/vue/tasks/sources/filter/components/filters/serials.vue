<template>
  <div>
    <h3>Serials</h3>
    <fieldset>
      <legend>Serials</legend>
      <smart-selector
        model="serials"
        klass="Source"
        target="Source"
        @selected="addSerial"/>
    </fieldset>
    <display-list
      :list="serials"
      label="object_tag"
      :delete-warning="false"
      @deleteIndex="removeSerial"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Serial } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    DisplayList
  },

  props: {
    modelValue: {
      type: Array,
      default: () => []
    }
  },

  emits: ['update:modelValue'],

  computed: {
    params: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      serials: [],
      allSerials: undefined
    }
  },

  watch: {
    value (newVal, oldVal) {
      if (!newVal.length && oldVal.length) {
        this.serials = []
      }
    },

    serials: {
      handler (newVal) {
        this.params = this.serials.map(serial => serial.id)
      },
      deep: true
    }
  },

  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (urlParams.serial_ids) {
      urlParams.serial_ids.forEach(id => {
        Serial.find(id).then(response => {
          this.addSerial(response.body)
        })
      })
    }
  },

  methods: {
    addSerial (serial) {
      if (!this.params.includes(serial.id)) {
        this.serials.push(serial)
      }
    },

    removeSerial (index) {
      this.serials.splice(index, 1)
    }
  }
}
</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>