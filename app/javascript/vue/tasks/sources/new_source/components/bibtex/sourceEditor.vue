<template>
  <fieldset v-help.section.BibTeX.editors>
    <legend>Editors</legend>
    <smart-selector
      model="people"
      target="Source"
      klass="Source"
      label="cached"
      :filter-ids="peopleIds"
      :params="{ role_type: 'SourceEditor' }"
      :autocomplete-params="{
        roles: ['SourceEditor']
      }"
      :autocomplete="false"
      @selected="addRole">
      <template #header>
        <role-picker
          ref="rolePicker"
          hidden-list
          v-model="roleAttributes"
          :autofocus="false"
          filter-by-role
          role-type="SourceEditor"/>
      </template>
      <role-picker
        v-model="roleAttributes"
        :create-form="false"
        :autofocus="false"
        filter-by-role
        role-type="SourceEditor"/>
    </smart-selector>
  </fieldset>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { findRole } from 'helpers/people/people.js'
import makePerson from 'factory/Person.js'
import RolePicker from 'components/role_picker.vue'
import SmartSelector from 'components/ui/SmartSelector'
import { ROLE_SOURCE_EDITOR } from 'constants/index.js'

export default {
  components: {
    RolePicker,
    SmartSelector
  },
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    },
    roleAttributes: {
      get () {
        return this.$store.getters[GetterNames.GetRoleAttributes]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRoles, value)
      }
    },
    peopleIds () {
      return this.roleAttributes.filter(item => item.person_id || item.person).map(item => item.person_id ? item.person_id : item.person.id)
    }
  },

  methods: {
    addRole (person) {
      if (!findRole(this.source.roles_attributes, person.id)) {
        this.$refs.rolePicker.setPerson(
          makePerson(
            person.first_name,
            person.last_name,
            person.id,
            ROLE_SOURCE_EDITOR)
        )
      }
    }
  }
}
</script>
