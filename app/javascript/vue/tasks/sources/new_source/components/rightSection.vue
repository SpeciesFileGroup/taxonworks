<template>
  <div class="right-section">
    <div
      class="overflow-y-auto"
      ref="section">
      <documents-component
        ref="documents"
        class="panel"/>
      <soft-validation
        v-if="areValidations"
        class="margin-medium-top soft-validation-panel"
        :validations="validations"/>
      <matches-component ref="matches"/>
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
    },
    areValidations () {
      return this.validations?.sources?.list.length
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
    this.scrollBox()
  },
  methods: {
    scrollBox () {
      const { documents, matches, section } = this.$refs
      const element = this.$el
      const sectionSize = section.getBoundingClientRect()
      const documentsSize = documents.$el.getBoundingClientRect()
      const matchesSize = matches.$el.getBoundingClientRect()
      const validationsSize = document.querySelector('.soft-validation-panel')?.getBoundingClientRect()?.height || 0

      const totalHeight = documentsSize.height + validationsSize + matchesSize.height
      const newHeight = (window.innerHeight - sectionSize.top) < totalHeight ? `${(window.innerHeight - sectionSize.top)}px` : 'auto'

      if (element.offsetTop < document.documentElement.scrollTop + 50) {
        this.$refs.section.classList.add('float-box')
      } else {
        this.$refs.section.classList.remove('float-box')
      }

      this.$refs.section.style.height = newHeight
    }
  }
}
</script>

<style lang="scss" scoped>
  .right-section {
    position: relative;
    min-width: 400px;
    max-width: 400px;
  }
  .float-box {
    top: 70px;
    width: 400px;
    position: fixed;
  }
</style>
