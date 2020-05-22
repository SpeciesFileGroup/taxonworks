<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Default units</h3>
    </div>
    <div class="body">
      <select 
        v-model="selected"
        class="normal-input">
        <option
          v-for="(label, key) in list"
          :value="key">{{ key }}: {{ label }}
        </option>
      </select>
      <button
        :disabled="!validateFields"
        @click="sendDescriptor"
        class="normal-input button button-submit"
        type="button">{{ descriptor['id'] ? 'Update' : 'Create' }}
      </button>
    </div>
  </div>
</template>
<script>

import { GetUnits } from '../../request/resources'

export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },
  computed: {
    validateFields() {
      return this.descriptor.name && this.selected
    }
  },
  data() {
    return {
      selected: undefined,
      list: undefined
    }
  },
  watch: {
    descriptor: {
      handler (newVal, oldVal) {
        if (newVal.hasOwnProperty('default_unit')) {
          this.selected = newVal.default_unit
        }
      },
      deep: true,
      immediate: true
    }
  },
  mounted() {
    GetUnits().then(response => {
      this.list = response
    })
  },
  methods: {
    sendDescriptor() {
      let newDescriptor = this.descriptor
      newDescriptor['default_unit'] = this.selected
      this.$emit('save', newDescriptor)
    }
  }
}
</script>