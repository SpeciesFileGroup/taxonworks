<template>
  <div class="packager-table margin-large-top margin-large-bottom">
    <h2>{{ title }} ({{ items.length }})</h2>
    <table class="table-striped packager-table__table">
      <thead>
        <tr>
          <th class="packager-table__col-zip">Zip</th>
          <th
            v-for="col in columns"
            :key="col.slot"
            :class="columnClass(col)"
          >
            {{ col.title }}
          </th>
          <th class="packager-table__col-size">Size</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in items"
          :key="itemKey(item)"
          :class="rowClass(item, index)"
        >
          <td class="packager-table__col-zip">
            {{
              item.available === false
                ? '—'
                : item.group_index
                  ? `Zip ${item.group_index}`
                  : '—'
            }}
          </td>
          <td
            v-for="col in columns"
            :key="col.slot"
            :class="columnClass(col)"
          >
            <slot :name="col.slot" :item="item" />
          </td>
          <td class="packager-table__col-size">
            {{ item.size ? formatBytes(item.size) : '—' }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { formatBytes } from './utils'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  items: {
    type: Array,
    required: true
  },
  columns: {
    type: Array,
    required: true,
    validator: (cols) => cols.every((c) => c.title && c.slot)
  },
  keyField: {
    type: String,
    default: 'id'
  }
})

function itemKey(item) {
  return item[props.keyField] || item.id || Math.random()
}

function rowClass(item, index) {
  const prevItem = index > 0 ? props.items[index - 1] : null
  const isGroupStart = prevItem && item.group_index !== prevItem.group_index

  return {
    'packager-table__row--unavailable': item.available === false,
    'packager-table__row--group-start': isGroupStart
  }
}

function columnClass(col) {
  return col.class || ''
}
</script>

<style scoped lang="scss">
.packager-table {
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

.packager-table__table {
  table-layout: fixed;
  width: 100%;
}

.packager-table__table th,
.packager-table__table td {
  padding: 0.65rem 0.85rem;
  vertical-align: top;
}

.packager-table__col-zip {
  width: 6%;
  white-space: nowrap;
}

.packager-table__col-size {
  width: 8%;
  white-space: nowrap;
}

.packager-table__row--unavailable {
  opacity: 0.5;
}

.packager-table__row--group-start td {
  border-top: 3px solid #2a6db0;
}

.packager-table__table td {
  overflow-wrap: anywhere;
  word-break: break-word;
}
</style>
