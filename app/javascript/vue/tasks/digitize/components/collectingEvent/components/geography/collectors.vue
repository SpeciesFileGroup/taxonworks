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
      <template #header>
        <role-picker
          hidden-list
          v-model="collectingEvent.roles_attributes"
          ref="rolepicker"
          :autofocus="false"
          role-type="Collector"/>
      </template>
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

import { GetterNames } from '../../../../store/getters/getters.js'
import refreshSmartSelector from '../../../shared/refreshSmartSelector'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [refreshSmartSelector, extendCE],

  components: {
    SmartSelector,
    RolePicker
  },

  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    }
  },

  methods: {
    roleExist (id) {
      return !!this.collectingEvent.roles_attributes.find(role => !role.hasOwnProperty('_destroy') && role.person_id === id)
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.$refs.rolepicker.addCreatedPerson({ object_id: role.id, label: role.cached })
      }
    }
  }
}
</script>
