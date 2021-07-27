<template>
  <div 
    v-if="isOtu">
    <h3>Copy and clone</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="radio"
            name="clone"
            :value="true"
            v-model="copy">
          Copy from
        </label>
      </li>
      <li>
        <label>
          <input
            type="radio"
            name="clone"
            :value="false"
            v-model="copy">
          Clone to
        </label>
      </li>
    </ul>
    <br>
    <ul class="no_bullets">
      <li
        v-for="(type, key) in objectType"
        :key="key">
        <label>
          <input
            type="radio"
            name="clone-type"
            :value="key"
            v-model="typeSelected">
          {{ type.label }}
        </label>
      </li>
    </ul>
    <div>
      <autocomplete
        class="separate-top separate-bottom"
        :url="objectType[typeSelected].url"
        min="2"
        param="term"
        label="label_html"
        :placeholder="`Search a ${objectType[typeSelected].label.toLowerCase()}`"
        :clear-after="true"
        display="label"
        @getItem="objectSelected = $event"/>
      <button
        type="button"
        :disabled="!objectSelected"
        @click="cloneScorings"
        class="button normal-input button-submit"
        v-html="buttonLabel"/>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete.vue'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    Autocomplete
  },
  computed: {
    isOtu() {
      return this.$store.getters[GetterNames.GetMatrixRow] && 
      (this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class == 'Otu' || this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class == 'CollectionObject')
    },
    rowGlobalId() {
      return this.$store.getters[GetterNames.GetMatrixRow].row_object.global_id
    },
    rowClass() {
      return this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class
    },
    buttonLabel() {
      return this.copy ? `Copy observation from  ${this.objectSelected ? this.objectSelected.label : '[pick object]'} to this ${this.rowClass}` : `Clone observations in this row to ${this.objectSelected ? this.objectSelected.label : '[pick object] '}`
    }
  },
  data() {
    return {
      copy: true,
      typeSelected: 'Otu',
      objectSelected: undefined,
      objectType: {
        Otu: { label: 'OTU', url: '/otus/autocomplete' },
        CollectionObject: { label: 'Collection Object', url: '/collection_objects/autocomplete' }
      }
    }
  },
  methods: {
    cloneScorings() {
      if(window.confirm('Are you sure you want to proceed?')) {
        this.$emit(this.copy ? 'onCopy' : 'onClone', {
          old_global_id: !this.copy ? this.rowGlobalId : this.objectSelected.gid,
          new_global_id: !this.copy ? this.objectSelected.gid : this.rowGlobalId
        })
        this.objectSelected = undefined
      }
    }
  }
}
</script>