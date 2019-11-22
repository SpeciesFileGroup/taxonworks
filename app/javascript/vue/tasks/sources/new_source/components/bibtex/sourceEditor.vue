<template>
  <fieldset>
    <legend v-help.section.BibTeX.editors>Editors</legend>
    <smart-selector
      v-model="view"
      class="separate-bottom"
      :options="options"/>
    <div
      v-if="view && view != 'new/Search'"
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
      ref="rolePicker"
      v-model="source.roles_attributes"
      :autofocus="false"
      :filter-by-role="true"
      role-type="SourceEditor"/>
  </fieldset>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import RolePicker from 'components/role_picker.vue'
import SmartSelector from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'

import OrderSmart from 'helpers/smartSelector/orderSmartSelector'
import SelectFirst from 'helpers/smartSelector/selectFirstSmartOption'

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
    AjaxCall('get', `/people/select_options?role_type=SourceEditor`).then(response => {
      let result = response.body
      this.options = OrderSmart(Object.keys(result))
      this.lists = response.body
      this.options.push('new/Search')
      this.view = SelectFirst(this.lists, this.options) ? SelectFirst(this.lists, this.options) : 'new/Search'
    })
  },
  methods: {
    roleExist(id) {
      return (this.source.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person') && role.person.id == id
      }) ? true : false)
    },
    addRole(person) {
      if(!this.roleExist(person.id)) {
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
