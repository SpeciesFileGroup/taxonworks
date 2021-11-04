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
          <th @click="sort('text')">Label</th>
          <th @click="sort('total')">Total</th>
          <th @click="sort('is_copy_edited')">Is copy edited</th>
          <th @click="sort('is_printed')">Is printed</th>
          <th @click="sort('type')">Type</th>
          <th @click="sort('updated_by')">Updated by</th>
          <th @click="sort('updated_at')">Updated at</th>
          <th @click="sort('on')">On</th>
          <th>Edit</th>
          <th>
            <button
              type="button"
              class="button normal-input button-delete"
              @click="deleteLabels">
              Destroy all selected
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
              :value="item">
          </td>
          <td>
            <pre v-html="item.label"/>
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

export default {
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

      set (value) {
        this.selected = value ? this.list.slice(0) : []
      }
    }
  },

  data () {
    return {
      currentSort: 'label',
      currentSortDir: 'asc'
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
      if (window.confirm('You\'re trying to delete this record(s). Are you sure want to proceed?')) {
        this.$emit('onRemove', label)
      }
    },

    deleteLabels () {
      if (window.confirm('You\'re trying to delete this record(s). Are you sure want to proceed?')) {
        this.$emit('onRemoveAll')
      }
    },

    updateLabel (label) {
      this.$emit('onUpdate', label)
    }
  }
}
</script>
