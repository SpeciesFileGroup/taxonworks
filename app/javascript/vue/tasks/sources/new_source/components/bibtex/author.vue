<template>
  <fieldset>
    <legend v-help.section.BibTeX.authors>Authors</legend>
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
      :autocomplete="false"
      @selected="addRole">
      <role-picker
        :create-form="view == 'search'"
        ref="rolePicker"
        v-model="source.roles_attributes"
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
