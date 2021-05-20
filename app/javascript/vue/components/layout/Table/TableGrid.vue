<template>
  <div
    class="table-grid"
    :style="gridStyle">
    <slot />
  </div>
</template>

<script>

import { convertToUnit } from 'helpers/style'

export default {
  props: {
    columns: {
      type: Number,
      required: true
    },

    gap: {
      type: [Number, String],
      default: 0
    },

    columnWidth: {
      type: Object,
      default: () => ({})
    }
  },

  computed: {
    styleColumnWidth () {
      const columnsCount = Number(this.columns)
      const values = []
      let index = 0

      for (let i = 0; i < columnsCount; i++) {
        if (this.columnWidth[i]) {
          if (index) {
            values.push(index)
            index = 0
          }
          values.push(convertToUnit(this.columnWidth[i]))
        } else {
          index++
        }
      }
      if (index) {
        values.push(index)
      }

      const data = values.reduce((accumulator, currentValue) =>
        accumulator + (isNaN(currentValue)
          ? `${currentValue} `
          : `repeat(${currentValue}, ${this.columnWidth.default || 'auto'}) `
        ), ''
      )

      return { 'grid-template-columns': data }
    },

    styleGap () {
      return { gap: convertToUnit(this.gap) }
    },

    gridStyle () {
      return Object.assign({},
        this.styleColumnWidth,
        this.styleGap
      )
    }
  }
}
</script>

<style lang="scss" scoped>
  .table-grid {
    display: grid;
  }
</style>
