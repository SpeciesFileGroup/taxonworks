<template>
  <div>
    <h2>Collectors</h2>
    <smart-selector
      v-model="view"
      name="collectors"
      :add-option="['search','new']"
      :options="options"/>
    <template v-if="view != 'search'">
      <ul>
        <li
          v-for="(item, key) in lists[view]"
          :key="key">
          <label>
            <input
              type="radio"
              v-model="collector"
              :value="item.id">
            <span v-html="item.object_tag"/>
          </label>
        </li>
      </ul>
    </template>
    <role-picker
      v-if="view == 'new' || view == 'search'"
      v-model="collector"
      :autofocus="false"
      role-type="Collector"/>
  </div>
</template>

<script>

import SmartSelector from '../../../../../../components/switch.vue'
import RolePicker from '../../../../../../components/role_picker.vue'
import { GetCollectorsSmartSelector } from '../../../../request/resources.js'
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

export default {
  components: {
    SmartSelector,
    RolePicker
  },
  computed: {
    collector: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent.roles_attributes]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventRoles, value)
      }
    }
  },
  data() {
    return {
      options: [],
      view: 'search',
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
        Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
        this.options = Object.keys(result)
        if(Object.keys(result).length) {
          this.view = Object.keys(result)[0]
        }
        this.lists = response
      })
    },
  }
}
</script>
