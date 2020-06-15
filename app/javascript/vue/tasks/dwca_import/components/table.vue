<template>
  <div>
    <table class="position-relative">
      <thead>
        <tr>
          <th
            class="position-sticky">
            Selected
          </th>
          <th
            class="position-sticky">
            Status
          </th>
          <th
            class="position-sticky"
            v-for="(item, index) in table.headers"
            :key="index">
            <div class="flex-separate middle">
              <span>{{ item }}</span>
              <column-filter
                :disabled="disabled"
                class="margin-medium-left"
                :import-id="importId"
                v-model="filters[index]"
                :field="index"/>
            </div>
          </th>
        </tr>
      </thead>
      <tbody>
        <row-component
          v-for="(row, index) in table.rows"
          class="contextMenuCells"
          :class="{ 'even': (index % 2 == 0) }"
          :id="row.id"
          :row="row"
          v-model="selectedIds"
          :import-id="importId"/>
      </tbody>
    </table>
  </div>
</template>

<script>

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'

export default {
  components: {
    RowComponent,
    ColumnFilter
  },
  props: {
    table: {
      type: Object,
      required: true
    },
    importId: {
      type: [String, Number],
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    },
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    selectedIds: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      filters: {},
      isProcessing: false
    }
  },
  watch: {
    filters: {
      handler (newVal) {
        this.$emit('onParams', newVal)
      },
      deep: true
    }
  }
}
</script>

<style scoped>
  th {
    top: 0
  }

  .show-import-process {
    width: 400px;
    position: fixed;
    bottom: 0px;
    height: 100px;
    z-index: 201;
    left: 50%;
    transform: translate(-50%);
  }
</style>
