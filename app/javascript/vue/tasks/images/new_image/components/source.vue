<template>
  <div class="panel content panel-section">
    <h2>Source</h2>
    <div class="flex-separate align-start">
      <div>
        <smart-selector
          v-model="view"
          class="separate-bottom"
          :options="options"/>
        <template v-if="view == 'search'">
          <autocomplete
            url="/sources/autocomplete"
            label="label_html"
            :placeholder="`Select a source`"
            :clear-after="true"
            @getItem="setSource"
            param="term"/>
        </template>
        <ul
          v-else
          class="no_bullets">
          <li
            v-for="item in lists[view]"
            :key="item.id">
            <label @click="setSource(item)">
              <input
                name="items-depic-some"
                :checked="source && source.id == item.id"
                type="radio">
              <span v-html="item.object_tag"/>
            </label>
          </li>
        </ul>
        <template v-if="source">
          <hr>
          <div class="middle">
            <span v-html="source.object_tag"/>
            <span
              @click="removeSource"
              class="circle-button button-default btn-undo"/>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import Autocomplete from 'components/autocomplete'

import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector.js'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption.js'
import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'

import { GetSourceSmartSelector } from '../request/resources.js'

export default {
  components: {
    SmartSelector,
    Autocomplete,
  },
  computed: {
    source: {
      get() {
        return this.$store.getters[GetterNames.GetSource]
      },
      set(value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    }
  },
  data() {
    return {
      options: ['search'],
      lists: [],
      view: 'search',
    }
  },
  mounted() {
    this.getSmartSelector()
  },
  methods: {
    setSource(value) {
      if(value.hasOwnProperty('label_html')) {
        value.object_tag = value.label_html
      }
      this.source = value
    },
    removeSource() {
      this.source = undefined
    },
    getSmartSelector() {
      GetSourceSmartSelector().then(response => {
        this.options = OrderSmartSelector(Object.keys(response.body))
        this.options.push('search')
        this.lists = response.body

        let selectedOption = SelectFirstSmartOption(this.lists, this.options)
        this.view = selectedOption ? selectedOption : 'search'
      })
    }
  }
}
</script>
<style scoped>
  li {
    margin-bottom: 4px;
  }
</style>