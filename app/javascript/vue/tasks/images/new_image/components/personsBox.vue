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
    }
  },
  data() {
    return {
      options: ['someone else', 'an organization'],
      view: 'someone else',
      roles_attributes: []
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