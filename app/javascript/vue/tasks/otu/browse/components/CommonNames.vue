<template>
  <section-panel title="Common names">
    <a name="common-names"/>
    <table-display 
      v-if="commonNames.length"
      :list="commonNames"
      :header="['Name', 'Geographic area', 'Language', 'Start year', 'End year', '']"
      :destroy="false"
      :attributes="['object_tag', ['geographic_area', 'object_tag'], 'language_tag', 'start_year', 'end_year']"/>
  </section-panel>
</template>

<script>

import { GetCommonNames } from '../request/resources.js'
import SectionPanel from './shared/sectionPanel'
import TableDisplay from 'components/table_list'

export default {
  components: {
    SectionPanel,
    TableDisplay
  },
  props: {
    otu: {
      type: Object
    }
  },
  data() {
    return {
      commonNames: []
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        if(newVal) {
          GetCommonNames(newVal.id).then(response => {
            this.commonNames = response.body
          })
        }
      },
      immediate: true
    }
  }
}
</script>
<style lang="scss" scoped>
  li {
    border-bottom: 1px solid #F5F5F5;
  }
</style>