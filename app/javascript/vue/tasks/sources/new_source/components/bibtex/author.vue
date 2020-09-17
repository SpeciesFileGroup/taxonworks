<template>
  <fieldset v-help.section.BibTeX.authors>
    <legend>Authors</legend>
    <smart-selector
      ref="smartSelector"
      model="people"
      @onTabSelected="view = $event"
      target="Source"
      klass="Source"
      :params="{ role_type: 'SourceAuthor' }"
      :autocomplete-params="{
        roles: ['SourceAuthor']
      }"
      :filter-ids="peopleIds"
      :autocomplete="false"
      @selected="addRole">
      <role-picker
        slot="header"
        ref="rolePicker"
        v-model="roleAttributes"
        :autofocus="false"
        :hidden-list="true"
        :filter-by-role="true"
        role-type="SourceAuthor"/>
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

import SmartSelector from 'components/smartSelector.vue'
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
      return this.roleAttributes.filter(item => item.person_id || item.person).map(item => item.person_id ? item.person_id : item.person.id)
    }
  },
  data () {
    return {
      options: [],
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
