<template>
  <div>
    <h1>Task - Print labels</h1>
    <div class="horizontal-left-content align-start">
      <style-selector/>
      <layout-component/>
      <preview-labels
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
      labels: []
    }
  }
}
</script>

