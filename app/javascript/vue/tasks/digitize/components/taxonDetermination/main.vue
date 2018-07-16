<template>
  <div>
    <smart-selector
      v-model="view"
      name="determination"
      :options="options"/>
    <label>OTU</label>
    <otu-picker @getItem="otu = $event.id"/> 
    <label>Determiner</label>
    <role-picker
      :autofocus="false" 
      v-model="roles"/>
    <div class="horizontal-left-content date-fields">
      <div class="separate-right">
        <label>Year</label>
        <input
          type="text"
          v-model="year">
      </div>
      <div class="separate-right separate-left">
        <label>Month</label>
        <input
          type="text"
          v-model="month">
      </div>
      <div class="separate-left">
        <label>Day</label>
        <input
          type="text"
          v-model="day">
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
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    SmartSelector,
    RolePicker,
    OtuPicker
  },
  computed: {
    otu: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDetermination].otu_id
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationOtuId, value)
      }
    },
    day: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDeterminationDay]
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationDay, value)
      }
    },
    month: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDeterminationMonth]
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationMonth, value)
      }
    },
    year: {
      get() {
        return this.$store.getters[GetterNames.GetTaxonDeterminationYear]
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationYear, value)
      }
    }
  },
  data() {
    return {
      roles: [],
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
