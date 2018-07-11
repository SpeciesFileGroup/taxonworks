<template>
  <div>
    <smart-selector
      v-model="view"
      name="determination"
      :options="options"/>
    <label>OTU</label>
    <otu-picker @getItem="otu = $event"/> 
    <label>Determiner</label>
    <role-picker
      :autofocus="false" 
      v-model="roles"/>
    <div class="horizontal-left-content date-fields">
      <div class="separate-right">
        <label>Year</label>
        <input type="text">
      </div>
      <div class="separate-right separate-left">
        <label>Month</label>
        <input type="text">
      </div>
      <div class="separate-left">
        <label>Day</label>
        <input type="text">
      </div>
    </div>
    <button
      type="button"
      class="button normal-input button-submit"
      @click="SaveMethod">Save</button>
  </div>
</template>

<script>

import SmartSelector from '../../../../components/switch.vue'
import RolePicker from '../../../../components/role_picker.vue'
import OtuPicker from '../../../../components/otu/otu_picker/otu_picker.vue'

export default {
  components: {
    SmartSelector,
    RolePicker,
    OtuPicker
  },
  data() {
    return {
      roles: [],
      otu: undefined,
      view: undefined,
      options: ['Quick', 'Recent', 'Pinboard', 'New']
    }
  },
  methods: {
    SaveMethod() {
      
    }
  }
}
</script>

<style lang="scss" scoped>
  label {
    display: block;
  }
  .date-fields {
    input {
      max-width: 60px;
    }
  }
</style>
