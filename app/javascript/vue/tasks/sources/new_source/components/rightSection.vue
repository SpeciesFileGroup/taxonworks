<template>
  <div class="right-section">
    <div class="content">
      <ul class="no_bullets context-menu">
        <li v-for="tab in tabs">
          <label>
            <input
              v-model="componentSelected"
              :value="tab.value"
              type="radio">
            {{ tab.label }}
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

export default {
  components: {
    SoftValidation,
    MatchesComponent
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
