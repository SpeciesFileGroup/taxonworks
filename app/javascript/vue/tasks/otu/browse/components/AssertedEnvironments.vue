<template>
  <section-panel
    :status="status"
    :title="title"
  >
    <table-display
      v-if="assertedEnvironments.length"
      :list="assertedEnvironments"
      :header="['Environment', '']"
      :destroy="false"
      :attributes="['uri_label']"
    />
  </section-panel>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import SectionPanel from './shared/sectionPanel'
import TableDisplay from '@/components/table_list'
import extendSection from './shared/extendSections'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    TableDisplay
  },
  computed: {
    assertedEnvironments() {
      return this.$store.getters[GetterNames.GetAssertedEnvironments]
    }
  }
}
</script>
