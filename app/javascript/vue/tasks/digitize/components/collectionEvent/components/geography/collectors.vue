<template>
  <fieldset>
    <legend>Collectors</legend>
    <smart-selector
      ref="smartSelector"
      model="people"
      @onTabSelected="view = $event"
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
        v-model="collectors"
        ref="rolepicker"
        :autofocus="false"
        role-type="Collector"/>
      <role-picker
        :create-form="false"
        v-model="collectors"
        :autofocus="false"
        role-type="Collector"/>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'

import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import CreatePerson from '../../../../helpers/createPerson.js'
import refreshSmartSelector from '../../../shared/refreshSmartSelector'

export default {
  mixins: [refreshSmartSelector],
  components: {
    SmartSelector,
    RolePicker
  },
  computed: {
    collectors: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].roles_attributes
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventRoles, value)
      }
    },
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    }
  },
  data () {
    return {
      view: undefined
    }
  },
  methods: {
    roleExist (id) {
      return (this.collectors.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.person_id == id
      }) ? true : false)
    },
    addRole (role) {
      if(!this.roleExist(role.id)) {
        this.$refs.rolepicker.addCreatedPerson({ object_id: role.id, label: role.cached })
      }
    }
  }
}
</script>
