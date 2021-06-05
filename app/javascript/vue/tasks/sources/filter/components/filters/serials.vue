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
import { GetSerial } from '../../request/resources'

export default {
  components: {
    SmartSelector,
    DisplayList
  },
  props: {
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    params: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
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
        this.params = this.serials.map(serial => { return serial.id })
      },
      deep: true
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (urlParams.serial_ids) {
      urlParams.serial_ids.forEach(id => {
        GetSerial(id).then(response => {
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
  ::v-deep .vue-autocomplete-input {
    width: 100%
  }
</style>