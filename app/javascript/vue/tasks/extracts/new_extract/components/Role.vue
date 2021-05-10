<template>
  <block-layout>
    <h3 slot="header">By</h3>
    <div slot="body">
      <smart-selector
        model="people"
        :params="{ role_type: 'SourceAuthor' }"
        :autocomplete-params="{
          roles: ['Extractor']
        }"
        @selected="addRole"
      />
      <role-picker
        class="margin-medium-top"
        role-type="Extractor"
        v-model="extract.roles_attributes"/>
    </div>
  </block-layout>
</template>

<script>

import SmartSelector from 'components/smartSelector.vue'
import componentExtend from './mixins/componentExtend'
import RolePicker from 'components/role_picker'
import BlockLayout from 'components/layout/BlockLayout'
import { CreatePerson } from 'helpers/persons/createPerson'

export default {
  mixins: [componentExtend],

  components: {
    SmartSelector,
    RolePicker,
    BlockLayout
  },

  methods: {
    roleExist (id) {
      return this.extract.roles_attributes.find(role => !role?._destroy && role.person_id === id)
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.extract.roles_attributes.push(CreatePerson(role, 'Extractor'))
      }
    }
  }
}
</script>
