<template>
  <div>
    <table class="position-relative">
      <thead>
        <tr>
          <th
            class="position-sticky">
            Selected
          </th>
          <status-filter
            class="position-sticky margin-medium-left"
            v-model="params.status"/>
          <column-filter
            v-for="(item, index) in table.headers"
            :key="index"
            :title="item"
            :disabled="disabled"
            class="position-sticky margin-medium-left"
            :import-id="importId"
            v-model="params.filter[item]"
            :field="index"/>
        </tr>
      </thead>
      <tbody>
        <row-component
          v-for="(row, index) in table.rows"
          class="contextMenuCells"
          :class="{ 'even': (index % 2 == 0) }"
          :id="row.id"
          :row="row"
          @onUpdate="updateRow"
          v-model="selectedIds"
          :import-id="importId"/>
      </tbody>
    </table>
  </div>
</template>

<script>

import RowComponent from './row'
import ColumnFilter from './ColumnFilter'
import StatusFilter from './StatusFilter'
import FilterStatus from '../const/filterStatus'

export default {
  components: {
    RowComponent,
    ColumnFilter,
    StatusFilter
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
      params: {
        filter: {},
        status: FilterStatus()
      },
      isProcessing: false
    }
  },
  watch: {
    params: {
      handler (newVal) {
        if(newVal.status.length === FilterStatus().length) {
          newVal.status = []
        }
        this.$emit('onParams', newVal)
      },
      deep: true
    }
  },
  methods: {
    updateRow (row) {
      this.$emit('onUpdateRow', row)
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
