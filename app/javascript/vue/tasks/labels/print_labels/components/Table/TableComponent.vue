<template>
  <div class="pl-table-scroll">
    <table>
      <thead>
        <tr>
          <th>
            <input
              v-model="selectAll"
              type="checkbox"
              v-tooltip="'Select all'">
          </th>
          <th
            v-for="col in sortableColumns"
            :key="col.key"
            class="pl-sortable-th"
            @click="sort(col.key)">
            <div class="pl-sortable-th-inner">
              <span class="pl-sortable-th-label">{{ col.label }}</span><VBtn
                class="sort-indicator"
                circle
                :color="currentSort === col.key ? 'primary' : 'muted'"
              ><VIcon
                name="alphabeticalSort"
                x-small
              /></VBtn>
            </div>
          </th>
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
          <td class="pl-label-cell">
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
          <td class="pl-capped-cell">{{ shortType(item.type) }}</td>
          <td v-html="(item.hasOwnProperty('updated_by') ? item.updated_by : '')"/>
          <td class="pl-capped-cell">
            <span v-tooltip="item.hasOwnProperty('updated_on') ? item.updated_on : item.created_at">
              {{ shortDate(item.hasOwnProperty('updated_on') ? item.updated_on : item.created_at) }}
            </span>
          </td>
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
import { vTooltip } from '@/directives'

export default {
  components: {
    VIcon,
    VBtn
  },

  directives: {
    tooltip: vTooltip
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

    // 'Label::Generated::UnitTrayHeader1' -> 'UnitTrayHeader1'
    shortType (type) {
      return type ? type.split('::').pop() : type
    },

    // '2026-07-18T20:53:12.500-05:00' -> '2026-07-18'
    shortDate (value) {
      return value ? value.split('T')[0] : value
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

/* Some cell content (a Ruby class name like Label::Generated::X, an ISO
   timestamp) has no spaces to wrap at, so default wrapping can't help —
   and `overflow-wrap` alone doesn't do anything either, since it only
   breaks content that's already confined to a limited width; with no cap
   here the table just keeps growing to fit the unbroken string instead of
   wrapping it. Capping these columns gives overflow-wrap something to
   actually act on. */
.pl-capped-cell {
  max-width: 200px;
  overflow-wrap: break-word;
}

/* Label can be as wide as its content wants when there's room, but should
   wrap (not force horizontal scroll) once space gets tight — down to a
   300px floor. Below that floor there's nowhere left to shrink, so the
   scroll wrapper below takes over instead. */
.pl-label-cell {
  min-width: 300px;
}

.pl-label-cell pre {
  white-space: pre-wrap;
  overflow-wrap: break-word;
}

/* Fallback for when even the 300px floor doesn't fit the viewport. */
.pl-table-scroll {
  overflow-x: auto;
}

.pl-sortable-th {
  cursor: pointer;
  user-select: none;
}

/* Flex lives on this inner wrapper, not the <th> itself — setting
   display: flex directly on a <th> overrides its default
   display: table-cell and breaks the whole row's table layout. The label
   can wrap to 2 lines here without dragging the button down onto its own
   line with it, since the button is a fixed-size flex sibling rather than
   part of the text's own line flow. */
.pl-sortable-th-inner {
  display: flex;
  align-items: center;
}

.pl-sortable-th-label {
  flex: 1;
}

.pl-sortable-th:hover {
  background-color: var(--table-row-bg-hover);
}

.sort-indicator {
  flex-shrink: 0;
  margin-left: 0.35em;
  vertical-align: middle;
}
</style>
