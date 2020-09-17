<template>
  <div class="horizontal-left-content">
    <div class="field separate-right">
      <label>Day</label><br>
      <input
        type="number"
        v-model="source.day">
    </div>
    <div class="field separate-right">
      <label v-help.section.BibTeX.month>Month</label><br>
      <select
        class="normal-input"
        v-model="source.month">
        <option 
          :value="null"/>
        <option
          v-for="(month, index) in months"
          :value="month.substring(0,3).toLowerCase()"
          :key="month">
          {{ month }}
        </option>
      </select>
    </div>
    <div class="field separate-right">
      <label v-help.section.BibTeX.year>Year</label><br>
      <input
        type="number"
        v-model="source.year">
    </div>
    <div class="field separate-right">
      <label v-help.section.BibTeX.yearSuffix>Year suffix</label><br>
      <input
        type="text"
        v-model="source.year_suffix">
    </div>
    <div class="field">
      <label v-help.section.BibTeX.yearStated>Stated year</label><br>
      <input
        type="number"
        v-model="source.stated_year">
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    },
  },
  data () {
    return {
      months: [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ]
    }
  }
}
</script>
<style scoped>
  input[type="number"] {
    width: 70px;
  }
</style>