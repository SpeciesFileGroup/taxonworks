<template>
  <div class="panel content panel-section">
    <h2>{{ title }}</h2>
    <smart-selector
      class="separate-bottom"
      :options="options"
      v-model="view"
    />
    <role-picker
      v-if="view == 'someone else'"
      v-model="roles_attributes"
      :role-type="roleType"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import RolePicker from 'components/role_picker'

export default {
  components: {
    SmartSelector,
    RolePicker
  },
  props: {
    title: {
      type: String,
      required: true
    },
    roleType: {
      type:String,
      required: true
    },
    options: {
      type: Array,
      default: () => { return ['someone else', 'an organization'] }
    },
    value: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      view: 'someone else',
      roles_attributes: []
    }
  },
  watch: {
    roles_attributes: {
      handler(newVal) {
        this.$emit('input', newVal)
      }, 
      deep: true
    },
    value: {
      handler(newVal) {
        this.roles_attributes = newVal
      },
      deep: true
    }
  },
  methods: {

  }
}
</script>
<style lang="scss">
  .switch-radio {
    label {
      width: 100%;
    }
  }
</style>