<template>
  <div>
    <smart-selector
      class="separate-bottom"
      :options="tabs"
      v-model="view"/>
    <ul
      v-if="isList"
      class="no_bullets">
      <li
        v-for="item in lists[view]"
        :key="item.id">
        <label>
          <input
            type="radio"
            @click="sendSelected(item.id)">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
    <sequence-picker
      :clear-after="true"
      @getItem="sendSelected($event.id)"/>
  </div>
</template>

<script>
import SmartSelector from 'components/switch'
import SequencePicker from 'components/sequence/sequence_picker/sequence_picker.vue'
import { GetSequenceSmartSelector, GetSequence } from '../../request/resources.js'
import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector.js'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption.js'
export default {
  props: {
    title: {
      type: String,
      required: true
    }
  },
  components: {
    SmartSelector,
    SequencePicker
  },
  computed: {
    isList() {
      return Object.keys(this.lists).includes(this.view)
    },
    selectedLabel() {
      return this.selected.hasOwnProperty('label_html') ? this.selected.label_html : this.selected.object_tag
    }
  },
  data () {
    return {
      lists: [],
      tabs: ['search'],
      view: undefined,
      selected: undefined
    }
  },
  mounted() {
    GetSequenceSmartSelector().then(response => {
      this.tabs = Object.keys(response.body)
      this.tabs.push('search')
      this.lists = response.body
    })
  },
  methods: {
    sendSelected(id) {
      GetSequence(id).then(response => {
        console.log(response)
        this.selected = response
        this.$emit('selected', response)        
      })
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%;
  }
</style>