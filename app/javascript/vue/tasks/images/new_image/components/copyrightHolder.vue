<template>
  <div class="panel content panel-section">
    <div>
      <h2>{{ title }}</h2>
    </div>
    <div class="flexbox">
      <div class="separate-right">
        <smart-selector
          class="separate-bottom"
          :options="options"
          v-model="view"/>
        <role-picker
          v-model="roles_attributes"
          :role-type="roleType"/>
      </div>
      <div class="separate-left">
        <label>
          Year of copyright
          <input type="number">
        </label>
      </div>
    </div>
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
      options: ['Someone else', 'An organization'],
      view: undefined,
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