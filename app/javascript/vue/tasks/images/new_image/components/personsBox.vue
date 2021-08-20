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
    <autocomplete
      v-else
      placeholder="Select an organization"
      url="/organizations/autocomplete"
      param="term"
      @getItem="setOrganization"
      label="label_html"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import RolePicker from 'components/role_picker'
import Autocomplete from 'components/ui/Autocomplete'

export default {
  components: {
    SmartSelector,
    RolePicker,
    Autocomplete
  },

  props: {
    title: {
      type: String,
      required: true
    },
    roleType: {
      type: String,
      required: true
    },
    options: {
      type: Array,
      default: () => ['someone else', 'an organization']
    },
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      view: 'someone else',
      roles_attributes: []
    }
  },

  watch: {
    roles_attributes: {
      handler (newVal) {
        this.$emit('update:modelValue', newVal)
      },
      deep: true
    },
    modelValue: {
      handler(newVal) {
        this.roles_attributes = newVal
      },
      deep: true
    }
  },

  methods: {
    setOrganization(organization) {
      this.roles_attributes = [{
        type: this.roleType,
        label: organization.label,
        organization_id: organization.id
      }]
    }
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