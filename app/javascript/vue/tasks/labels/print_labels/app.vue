<template>
  <div>
    <h1>Task - Print labels</h1>
    <div class="horizontal-left-content align-start">
      <style-selector
        @selected="styleSelected = $event"/>
      <layout-component
        @onRowsChange="layout.rows = $event"
        @onColumnsChange="layout.columns = $event"
        @onDivisorChange="layout.divisor = $event"/>
      <preview-labels
        :class-selected="styleSelected"
        :rows="layout.rows"
        :columns="layout.columns"
        :divisor="layout.divisor"
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
      styleSelected: undefined,
      layout: {
        rows: 0,
        columns: 0,
        divisor: false
      }
    }
  }
}
</script>

