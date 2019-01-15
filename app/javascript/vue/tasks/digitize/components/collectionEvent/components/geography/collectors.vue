<template>
  <fieldset>
    <legend>Collectors</legend>
    <smart-selector
      v-model="view"
      class="separate-bottom"
      name="collectors"
      :add-option="['new/Search']"
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
      v-model="collectors"
      :autofocus="false"
      role-type="Collector"/>
  </fieldset>
</template>

<script>

import SmartSelector from '../../../../../../components/switch.vue'
import RolePicker from '../../../../../../components/role_picker.vue'
import { GetCollectorsSmartSelector } from '../../../../request/resources.js'
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import CreatePerson from '../../../../helpers/createPerson.js'
import orderSmartSelector from '../../../../helpers/orderSmartSelector.js'
import selectFirstSmartOption from '../../../../helpers/selectFirstSmartOption'

export default {
  components: {
    SmartSelector,
    RolePicker,
    CreatePerson
  },
  computed: {
    collectors: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].roles_attributes
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventRoles, value)
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
    this.GetSmartSelector()
  },
  methods: {
    GetSmartSelector() {
      GetCollectorsSmartSelector().then(response => {
        let result = response
        this.options = orderSmartSelector(Object.keys(result))
        this.lists = response
        this.view = selectFirstSmartOption(response, this.options)
      })
    },
    roleExist(id) {
      return (this.collectors.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person') && role.person.id == id
      }) ? true : false)
    },
    addRole(role) {
      if(!this.roleExist(role.id)) {
        this.collectors.push(CreatePerson(role, 'Collector'))
      }
    }
  }
}
</script>
