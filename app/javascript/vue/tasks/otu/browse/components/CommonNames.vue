<template>
  <section-panel
    :status="status"
    :title="title">
    <table-display 
      v-if="commonNames.length"
      :list="commonNames"
      :header="['Name', 'Geographic area', 'Language', 'Start year', 'End year', '']"
      :destroy="false"
      :attributes="['object_tag', ['geographic_area', 'object_tag'], 'language_tag', 'start_year', 'end_year']"/>
  </section-panel>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import SectionPanel from './shared/sectionPanel'
import TableDisplay from 'components/table_list'
import extendSection from './shared/extendSections'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    TableDisplay
  },
  computed: {
    commonNames () {
      return this.$store.getters[GetterNames.GetCommonNames]
    }
  }
}
</script>
<style lang="scss" scoped>
  li {
    border-bottom: 1px solid #F5F5F5;
  }
</style>