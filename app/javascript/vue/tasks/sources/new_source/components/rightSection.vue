<template>
  <div class="right-section">
    <div ref="section">
      <documents-component
        class="panel"/>
      <soft-validation
        v-if="validations"
        class="margin-medium-top"
        :validations="validations"/>
      <matches-component/>
    </div>
  </div>
</template>

<script>

import DocumentsComponent from './documents'
import SoftValidation from 'components/soft_validations/panel'
import MatchesComponent from './matches'
import { GetterNames } from '../store/getters/getters'
export default {
  components: {
    SoftValidation,
    MatchesComponent,
    DocumentsComponent
  },
  computed: {
    validations () {
      return this.$store.getters[GetterNames.GetSoftValidation]
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
          this.$refs.section.style.width = `${element.getBoundingClientRect().width}px`
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
