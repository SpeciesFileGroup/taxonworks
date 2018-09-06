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
    <autocomplete
      v-if="view == 'search'"
      url="/url"
      placeholder="Search"
      min="2"
      label="label_html"
      param="term"/>
  </div>
</template>

<script>

import SmartSelector from '../../../../../../components/switch.vue'
import Autocomplete from '../../../../../../components/autocomplete.vue'
import { GetCollectorsSmartSelector } from '../../../../request/resources.js'
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  computed: {
    collector: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent.collector]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventCollectors, value)
      }
    }
  },
  data() {
    return {
      options: [],
      view: undefined,
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

<style>

</style>
