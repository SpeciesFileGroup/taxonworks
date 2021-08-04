<template>
  <fieldset v-help.section.BibTeX.editors>
    <legend>Editors</legend>
    <smart-selector
      model="people"
      ref="smartSelector"
      target="Source"
      @onTabSelected="view = $event"
      klass="Source"
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

import RolePicker from 'components/role_picker.vue'
import SmartSelector from 'components/ui/SmartSelector'

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
  data () {
    return {
      view: undefined
    }
  },
  watch: {
    lastSave: {
      handler (newVal, oldVal) {
        if (newVal !== oldVal) {
          this.$refs.smartSelector.refresh()
        }
      }
    }
  },
  methods: {
    roleExist (id) {
      return (this.source.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && (role.person_id === id || (role.hasOwnProperty('person') && role.person.id === id))
      }) ? true : false)
    },
    addRole (person) {
      if (!this.roleExist(person.id)) {
        this.$refs.rolePicker.setPerson(this.createPerson(person, 'SourceEditor'))
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
