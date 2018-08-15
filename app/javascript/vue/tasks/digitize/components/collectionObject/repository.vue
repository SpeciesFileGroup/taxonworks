<template>
  <div>
    <h2>Repository</h2>
    <smart-selector 
      name="repository"
      v-model="view"
      :add-option="['search']"
      :options="options"/>
    <ul v-if="view != 'search'">
      <li
        v-for="(item, key) in lists[view]"
        :key="key">
        <label>
          <input
            type="radio"
            v-model="repository"
            :value="item.id">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
    <div v-else>
      <autocomplete
        url="/repositories/autocomplete"
        label="label_html"
        param="term"
        placeholder="Search"
        @getItem="repository = $event.id"
        min="2"/>
    </div>
  </div>
</template>

<script>

import Autocomplete from '../../../../components/autocomplete'
import SmartSelector from '../../../../components/switch'
import { GetRepositorySmartSelector } from '../../request/resources.js'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    Autocomplete,
    SmartSelector
  },
  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    repository: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      },
      set(value) {
        return this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value)
      }
    }
  },
  data() {
    return {
      view: 'search',
      options: [],
      lists: []
    }
  },
  mounted() {
    this.loadTabList()
  },
  methods: {
    loadTabList() {
      GetRepositorySmartSelector().then(response => {
        let result = response
        Object.keys(result).forEach(key => (!result[key].length) && delete result[key])
        this.options = Object.keys(result)
        if(Object.keys(result).length) {
          this.view = Object.keys(result)[0]
        }
        this.lists = response
      })
    }
  }
}
</script>

<style>

</style>
