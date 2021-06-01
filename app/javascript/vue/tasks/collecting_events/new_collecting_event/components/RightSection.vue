<template>
  <div class="right-section">
    <div ref="section">
      <soft-validation
        :validations="softValidation"
        class="soft-validation-box margin-medium-top "/>
      <matches-component
        class="margin-medium-top"
        @select="$emit('select', $event)"
        :collecting-event="collectingEvent"/>
    </div>
  </div>
</template>

<script>

import SoftValidation from 'components/soft_validations/panel'
import { GetterNames } from '../store/getters/getters'
import MatchesComponent from './Matches'
import extendCE from './mixins/extendCE'

export default {
  mixins: [extendCE],

  components: {
    SoftValidation,
    MatchesComponent
  },

  computed: {
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidations]
    }
  },

  mounted () {
    window.addEventListener('scroll', this.scrollBox)
  },

  methods: {
    scrollBox () {
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
    min-width: 400px;
  }
  .float-box {
    top: 55px;
    width: 400px;
    min-width: 400px;
    position: fixed;
  }
</style>
