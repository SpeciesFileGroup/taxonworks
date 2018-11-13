<template>
  <div>
    <role-picker
      v-model="roles"
      :role-type="roleType"/>
  </div>
</template>

<script>

import RolePicker from 'components/role_picker'

export default {
  components: {
    RolePicker
  },
  props: {
    value: {
      type: Array,
      default: () => { return [] }
    },
    roleType: {
      type: String,
      required: true
    }
  },
  computed: {
    roles: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>

<style>

</style>
