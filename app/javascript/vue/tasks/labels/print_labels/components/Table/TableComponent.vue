<template>
  <div>
    <label-form
      :show-modal="showModalCreate"
      @close="showModalCreate = false"
      @save="createLabel($event); showModalCreate = false"/>
    <label-form
      v-if="selectedLabel"
      :show-modal="showModal"
      :value="selectedLabel"
      @close="showModal = false"
      @save="updateLabel($event); showModal = false"/>
    <option-buttons
      @selectAll="selectAll"
      @new="showModalCreate = true"
      @destroyAll="deleteLabels"/>
    <table>
      <thead>
        <tr>
          <th>Select</th>
          <th @click="sort('text')">Label</th>
          <th @click="sort('total')">Total</th>
          <th @click="sort('is_copy_edited')">Is copy edited</th>
          <th @click="sort('is_printed')">Is printed</th>
          <th @click="sort('updated_by')">Updated by</th>
          <th @click="sort('updated_at')">Updated at</th>
          <th @click="sort('on')">On</th>
          <th>Edit</th>
          <th>Destroy</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in sortedList"
          :key="item.id">
          <td>
            <checkbox-component
              v-model="selected"
              :val="item"/>
          </td>
          <td>
            <pre>{{ item.text }}</pre>
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

import LabelForm from '../LabelForm'
import OptionButtons from './OptionButtons'
import CheckboxComponent from './CheckboxComponent'
import { GetLabels, RemoveLabel, UpdateLabel, CreateLabel } from '../../request/resources.js'

export default {
  components: {
    LabelForm,
    OptionButtons,
    CheckboxComponent
  },
  computed: {
    sortedList() {
      return this.list.sort((a,b) => {
        let modifier = 1
        if(this.currentSortDir === 'desc') modifier = -1
        if(a[this.currentSort] < b[this.currentSort]) return -1 * modifier
        if(a[this.currentSort] > b[this.currentSort]) return 1 * modifier
        return 0
      });
    }
  },
  data() {
    return {
      list: [],
      currentSort: 'label',
      currentSortDir: 'asc',
      showModal: false,
      showModalCreate: false,
      selectedLabel: undefined,
      selected: []
    }
  },
  watch: {
    selected(newVal) {
      this.$emit('selected', newVal)
    }
  },
  mounted() {
    GetLabels().then(response => {
      this.list = response.body
    })
  },
  methods: {
    setEdit(label) {
      this.selectedLabel = label
      this.showModal = true
    },
    sort(s) {
      if(s === this.currentSort) {
        this.currentSortDir = (this.currentSortDir === 'asc' ? 'desc':'asc')
      }
      this.currentSort = s
    },
    selectAll() {
      this.selected = this.list.slice(0)
    },
    selectMyLabels() {
      //Needs endpoint for this
    },
    removeRow(label) {
      if(window.confirm(`You're trying to delete this record(s). Are you sure want to proceed?`)) {
        this.removeLabel(label)
      }
    },
    removeLabel(label) {
      RemoveLabel(label.id).then(() => {
        this.list.splice(this.list.findIndex(item => {
          return item.id === label.id
        }),1)
      })
    },
    deleteLabels() {
      if(window.confirm(`You're trying to delete this record(s). Are you sure want to proceed?`)) {
        this.selected.forEach((label, index) => {
          this.removeLabel(label)
        })
        this.selected = []
      }
    },
    createLabel(label) {
      CreateLabel(label).then(response => {
        this.list.push(response.body)
      })
    },
    updateLabel(label) {
      UpdateLabel(label).then(response => {
        const index = this.list.findIndex(item => {
          return item.id === label.id
        })
        this.$set(this.list, index, response.body)
      })
    }
  }
}
</script>

