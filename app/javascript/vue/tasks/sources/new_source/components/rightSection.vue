<template>
  <div class="right-section">
    <div ref="section">
      <soft-validation class="soft-validation-box"/>
      <matches-component/>
    </div>
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
  },
  mounted () {
    window.addEventListener('scroll', this.scrollBox)
  },
  methods: {
    scrollBox (event) {
      const element = this.$el
      if (element) {
        if (element.offsetTop < document.documentElement.scrollTop + 50) {
          this.$refs.section.classList.add('float-box')
        } else {
          this.$refs.section.classList.remove('float-box')
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
  .right-section {
    position: relative;
    width: 400px;
  }
  .float-box {
    top: 70px;
    position: fixed;
  }
</style>
