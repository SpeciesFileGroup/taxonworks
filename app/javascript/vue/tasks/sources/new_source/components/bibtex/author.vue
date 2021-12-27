<template>
  <fieldset v-help.section.BibTeX.authors>
    <legend>Authors</legend>
    <smart-selector
      model="people"
      @onTabSelected="view = $event"
      target="Source"
      klass="Source"
      label="cached"
      :params="{ role_type: 'SourceAuthor' }"
      :autocomplete-params="{
        roles: ['SourceAuthor']
      }"
      :filter-ids="peopleIds"
      :autocomplete="false"
      @selected="addRole">
      <template #header>
        <role-picker
          ref="rolePicker"
          v-model="roleAttributes"
          :autofocus="false"
          :hidden-list="true"
          :filter-by-role="true"
          role-type="SourceAuthor"/>
      </template>
      <role-picker
        :create-form="false"
        v-model="roleAttributes"
        :autofocus="false"
        :filter-by-role="true"
        role-type="SourceAuthor"/>
    </smart-selector>
  </fieldset>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { findRole } from 'helpers/people/people.js'
import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'

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
      return this.roleAttributes.filter(item => item.person_id || item.person).map(item => item?.person_id || item.person.id)
    }
  },

  data () {
    return {
      options: [],
      view: undefined
    }
  },

  methods: {
    addRole (person) {
      if (!findRole(this.source.roles_attributes, person.id)) {
        this.$refs.rolePicker.setPerson(this.createPerson(person, 'SourceAuthor'))
      }
    },

    createPerson (person, roleType) {
      return {
        first_name: person.first_name,
        last_name: person.last_name,
        person_id: person.id,
        type: roleType
      }
    }
  }
}
</script>
