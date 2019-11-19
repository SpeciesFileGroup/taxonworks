<template>
  <fieldset>
    <legend v-help.section.BibTeX.authors>Authors</legend>
    <smart-selector
      v-model="view"
      class="separate-bottom"
      :options="options"/>
    <div
      v-if="view != 'new/Search'"
      class="separate-bottom">
      <ul v-if="lists[view].length" class="no_bullets">
        <li
          v-for="item in lists[view]"
          :key="item.id"
          v-if="!roleExist(item.id)">
          <label>
            <input
              type="radio"
              :checked="roleExist(item.id)"
              @click="addRole(item)"
              :value="item.id">
            <span v-html="item.object_tag"/>
          </label>
        </li>
      </ul>
    </div>
    <role-picker
      v-model="source.roles_attributes"
      :autofocus="false"
      :filter-by-role="true"
      role-type="SourceAuthor"/>
  </fieldset>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import RolePicker from 'components/role_picker.vue'
import SmartSelector from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'

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
    }
  },
  data() {
    return {
      options: [],
      view: 'new/Search',
      lists: undefined
    }
  },
  mounted() {
    AjaxCall('get', `/people/select_options?role_type=SourceAuthor`).then(response => {
      let result = response.body
      this.options = Object.keys(result)
      this.lists = response.body
      this.options.push('new/Search')
    })
  },
  methods: {
    roleExist(id) {
      return (this.source.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person') && role.person.id == id
      }) ? true : false)
    },
    addRole(person) {
      if(!this.roleExist(role.id)) {
        this.roles.push(this.createPerson(person, 'SourceAuthor'))
      }
    },
    createPerson (person, type) {
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
