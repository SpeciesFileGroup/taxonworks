<template>
  <fieldset>
    <legend>Collectors</legend>
    <smart-selector
      ref="smartSelector"
      model="people"
      target="CollectingEvent"
      klass="CollectingEvent"
      :params="{ role_type: 'Collector' }"
      :autocomplete-params="{
        roles: ['Collector']
      }"
      :autocomplete="false"
      @selected="addRole">
      <role-picker
        slot="header"
        :hidden-list="true"
        v-model="collectingEvent.roles_attributes"
        ref="rolepicker"
        :autofocus="false"
        role-type="Collector"/>
      <role-picker
        :create-form="false"
        v-model="collectingEvent.roles_attributes"
        :autofocus="false"
        role-type="Collector"/>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'
import extendCE from '../mixins/extendCE.js'

export default {
  mixins: [extendCE],
  components: {
    SmartSelector,
    RolePicker
  },
  methods: {
    roleExist (id) {
      this.collectingEvent.roles_attributes.find(role => !role?._destroy && role.person_id === id)
    },
    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.$refs.rolepicker.addCreatedPerson({ object_id: role.id, label: role.cached })
      }
    }
  }
}
</script>
