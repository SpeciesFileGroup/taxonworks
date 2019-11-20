<template>
  <div class="right-section">
    <div class="content">
      <ul class="no_bullets context-menu">
        <li>
          <label>
            <input
              v-model="componentSelected"
              value="MatchesComponent"
              type="radio">
            Matches
          </label>
        </li>
        <li>
          <label>
            <input
              v-model="componentSelected"
              value="SoftValidation"
              :disabled="!source.id"
              type="radio">
            Soft validation
          </label>
        </li>
      </ul>
    </div>
    <component :is="componentSelected"/>
  </div>
</template>

<script>

import SoftValidation from './softValidation'
import MatchesComponent from './matches'
import { GetterNames } from '../store/getters/getters'
export default {
  components: {
    SoftValidation,
    MatchesComponent
  },
  computed: {
    source () {
      return this.$store.getters[GetterNames.GetSource]
    }
  },
  data () {
    return {
      tabs: [
        {
          label: 'Matches',
          value: 'MatchesComponent'
        },
        {
          label: 'Soft validation', 
          value: 'SoftValidation'
        }
      ],
      componentSelected: 'MatchesComponent'
    }
  }
}
</script>

<style scoped>
  .right-section {
    width: 400px;
  }
</style>
