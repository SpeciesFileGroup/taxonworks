<template>
  <block-layout>
    <template #header>
      <h3>By</h3>
    </template>
    <template #body>
      <smart-selector
        model="people"
        :params="{ role_type: 'SourceAuthor' }"
        :autocomplete-params="{
          roles: ['Extractor']
        }"
        label="cached"
        @selected="addRole"
      />
      <role-picker
        class="margin-medium-top"
        role-type="Extractor"
        v-model="extract.roles_attributes"/>
    </template>
  </block-layout>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import componentExtend from './mixins/componentExtend'
import RolePicker from 'components/role_picker'
import BlockLayout from 'components/layout/BlockLayout'
import makePerson from 'factory/Person'
import { findRole } from 'helpers/people/people.js'

export default {
  mixins: [componentExtend],

  components: {
    SmartSelector,
    RolePicker,
    BlockLayout
  },

  methods: {
    addRole (role) {
      if (!findRole(this.extract.roles_attributes, role.id)) {
        this.extract.roles_attributes.push(
          makePerson(
            role.first_name,
            role.last_name,
            role.person_id,
            'Extractor'
          ))
      }
    }
  }
}
</script>
