<template>
  <div>
    <h1>Task - Print labels</h1>
    <div class="horizontal-left-content align-start separate-bottom">
      <style-selector
        class="separate-right"
        v-model="styleSelected"/>
      <layout-component
        class="separate-left separate-right"
        @onRowsChange="layout.rows = $event"
        @onColumnsChange="layout.columns = $event"
        @onSeparatorChange="layout.separator = $event"
        @onDivisorChange="layout.divisor = $event"/>
      <preview-labels
        :disabled="!styleSelected"
        class="separate-left"
        :class-selected="styleSelected"
        :rows="layout.rows"
        :columns="layout.columns"
        :divisor="layout.divisor"
        :separator="layout.separator"
        :labels="labels"/>
    </div>
    <table-component @selected="labels = $event"/>
  </div>
</template>

<script>

import StyleSelector from './components/StyleSelector'
import LayoutComponent from './components/Layout'
import TableComponent from './components/Table/TableComponent'
import PreviewLabels from './components/PreviewLabels'

export default {
  components: {
    StyleSelector,
    LayoutComponent,
    TableComponent,
    PreviewLabels
  },
  data() {
    return {
      labels: [],
      styleSelected: 'ce_lbl_insect_compressed',
      layout: {
        rows: 151,
        columns: 9,
        separator: '',
        divisor: false
      }
    }
  }
}
</script>

