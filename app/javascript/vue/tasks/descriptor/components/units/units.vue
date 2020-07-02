<template>
  <div class="field label-above">
    <label>Default units</label>
    <select
      v-model="descriptor.default_unit"
      class="normal-input">
      <option
        v-for="(label, key) in list"
        :key="key"
        :value="key">{{ key }}: {{ label }}
      </option>
    </select>
  </div>
</template>
<script>

import { GetUnits } from '../../request/resources'

export default {
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    validateFields () {
      return this.descriptor.name && this.descriptor.default_unit
    },
    descriptor: {
      get () {
        return this.value
      },
      set () {
        this.$emit('input', this.value)
      }
    }
  },
  data () {
    return {
      list: undefined
    }
  },
  mounted () {
    GetUnits().then(response => {
      this.list = response.body
    })
  }
}
</script>