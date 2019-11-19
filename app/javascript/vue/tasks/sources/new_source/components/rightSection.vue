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

export default {
  components: {
    SoftValidation
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
      componentSelected: 'SoftValidation'
    }
  }
}
</script>

<style scoped>
  .right-section {
    width: 400px;
  }
</style>
