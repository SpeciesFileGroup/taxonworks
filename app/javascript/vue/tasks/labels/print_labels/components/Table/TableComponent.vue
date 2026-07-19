<template>
  <div>
    <table>
      <thead>
        <tr>
          <th>
            <label class="horizontal-left-content middle">
              <input
                class="margin-small-right"
                v-model="selectAll"
                type="checkbox">
              Select
            </label>
          </th>
          <th
            v-for="col in sortableColumns"
            :key="col.key"
            class="pl-sortable-th"
            @click="sort(col.key)">{{ col.label }}<VBtn
              class="sort-indicator"
              circle
              :color="currentSort === col.key ? 'primary' : 'muted'"
            ><VIcon
              name="alphabeticalSort"
              x-small
            /></VBtn></th>
          <th>Edit</th>
          <th>
            <button
              type="button"
              class="button normal-input button-delete"
              @click="deleteLabels">
              Destroy selected labels
            </button>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in sortedList"
          class="contextMenuCells"
          :class="{ even: index % 2 }"
          :key="item.id">
          <td>
            <input
              type="checkbox"
              v-model="selected"
              :value="item.id"
            >
          </td>
          <td>
            <div
              v-if="item.is_generated"
              v-html="item.label"
            />
            <pre
              v-else
              v-html="item.label"
            />
          </td>
          <td v-html="item.total"/>
          <td>
            <input
              type="checkbox"
              :checked="item.is_copy_edited"
              v-model="item.is_copy_edited"
              @change="updateLabel(item)">
          </td>
          <td>
            <input
              type="checkbox"
              :checked="item.is_printed"
              v-model="item.is_printed"
              @change="updateLabel(item)">
          </td>
          <td>{{ item.type }}</td>
          <td v-html="(item.hasOwnProperty('updated_by') ? item.updated_by : '')"/>
          <td v-html="(item.hasOwnProperty('updated_on') ? item.updated_on : item.created_at)"/>
          <td v-html="item.on"/>
          <td>
            <button
              type="button"
              class="button circle-button btn-edit"
              @click="setEdit(item)"/>
          </td>
          <td>
            <button
              type="button"
              class="button circle-button btn-delete"
              @click="removeRow(item)"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

export default {
  components: {
    VIcon,
    VBtn
  },

  props: {
    list: {
      type: Array,
      required: true
    },
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'onRemove',
    'onRemoveAll',
    'onEdit',
    'onUpdate'
  ],

  computed: {
    sortedList () {
      return this.list.slice(0).sort((a, b) => {
        let modifier = 1
        if (this.currentSortDir === 'desc') { modifier = -1 }
        if (a[this.currentSort] < b[this.currentSort]) return -1 * modifier
        if (a[this.currentSort] > b[this.currentSort]) return 1 * modifier
        return 0
      })
    },

    selected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    selectAll: {
      get () {
        return this.list.length === this.selected.length
      },

      set (isChecked) {
        this.selected = isChecked
          ? this.list.map(label => label.id)
          : []
      }
    }
  },

  data () {
    return {
      currentSort: 'text',
      currentSortDir: 'asc',
      sortableColumns: [
        { key: 'text', label: 'Label' },
        { key: 'total', label: 'Total' },
        { key: 'is_copy_edited', label: 'Is copy edited' },
        { key: 'is_printed', label: 'Is printed' },
        { key: 'type', label: 'Type' },
        { key: 'updated_by', label: 'Updated by' },
        { key: 'updated_at', label: 'Updated at' },
        { key: 'on', label: 'On' }
      ]
    }
  },

  methods: {
    setEdit (label) {
      this.$emit('onEdit', label)
    },

    sort (s) {
      if (s === this.currentSort) {
        this.currentSortDir = (this.currentSortDir === 'asc' ? 'desc' : 'asc')
      }
      this.currentSort = s
    },

    removeRow (label) {
      if (window.confirm("You're trying to delete this label. Are you sure you want to proceed?")) {
        this.$emit('onRemove', label.id)
      }
    },

    deleteLabels () {
      if (window.confirm("You're trying to delete this label(s). Are you sure you want to proceed?")) {
        this.$emit('onRemoveAll')
      }
    },

    updateLabel (label) {
      this.$emit('onUpdate', label)
    }
  }
}
</script>

<style scoped>
/* The global `table th` rule (helpers/list/tables.scss) sets 12px, smaller
   than TW's own $font_normal (13px) — bumping it here so the sort
   indicator (sized relative to it) isn't fighting an already-tiny base. */
thead th {
  font-size: 13px;
}

.pl-sortable-th {
  cursor: pointer;
  user-select: none;
  white-space: nowrap;
}

.pl-sortable-th:hover {
  background-color: var(--table-row-bg-hover);
}

.sort-indicator {
  margin-left: 0.35em;
  vertical-align: middle;
}
</style>
