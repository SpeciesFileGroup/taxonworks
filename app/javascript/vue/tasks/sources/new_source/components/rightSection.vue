<template>
  <div class="right-section">
    <soft-validation/>
    <matches-component/>
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
