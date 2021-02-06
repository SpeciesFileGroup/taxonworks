<template>
  <div class="panel content">
    <h3>Person</h3>
    <div class="field">
      <label>Source source</label>
      <role-picker
        v-model="source.roles_attributes"
        :autofocus="false"
        role-type="SourceSource"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import RolePicker from 'components/role_picker.vue'

export default {
  components: {
    RolePicker
  },
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    }
  }
}
</script>