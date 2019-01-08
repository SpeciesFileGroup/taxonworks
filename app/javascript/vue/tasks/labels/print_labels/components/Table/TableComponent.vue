<template>
  <div>
    <option-buttons
      @selectAll="selectAll"
      @destroyAll="deleteLabels"/>
    <table>
      <thead>
        <tr>
          <th>Select</th>
          <th>Label</th>
          <th>Edit</th>
          <th>Is printed</th>
          <th>Is copy edited</th>
          <th>Updated by</th>
          <th>Updated on</th>
          <th>On</th>
          <th>Show</th>
          <th>Total</th>
          <th>Destroy</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td>
            <checkbox-component
              v-model="selected"
              :val="item"/>
          </td>
          <td>
            <pre>{{ item.text }}</pre>
          </td>
          <td>
            <button
              type="button"
              class="button circle-button btn-edit"/>
          </td>
          <td>
            <input
              type="checkbox"
              :checked="item.is_printed"
              v-model="item.is_printed"
              @change="updateLabel(item)">
          </td>
          <td>
            <input
              type="checkbox"
              :checked="item.is_copy_edited"
              v-model="item.is_copy_edited"
              @change="updateLabel(item)">
          </td>
          <td v-html="(item.hasOwnProperty('updated_by') ? item.updated_by : '')"/>
          <td v-html="(item.hasOwnProperty('updated_on') ? item.updated_on : item.created_at)"/>
          <td>On</td>
          <td>
            <a
              :href="`/labels/${item.id}`"
              target="blank">
              Show
            </a>
          </td>
          <td v-html="item.total"/>
          <td>
            <button
              type="button"
              class="button circle-button btn-delete"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>

import OptionButtons from './OptionButtons'
import CheckboxComponent from './CheckboxComponent'
import { GetLabels, RemoveLabel, UpdateLabel } from '../../request/resources.js'

export default {
  components: {
    OptionButtons,
    CheckboxComponent
  },
  data() {
    return {
      list: [],
      selected: []
    }
  },
  watch: {
    selected(newVal) {
      this.$emit('selected', newVal)
    }
  },
  mounted() {
    console.log(document.cookie)
    GetLabels().then(response => {
      this.list = response
    })
  },
  methods: {
    selectAll() {
      this.selected = this.list.slice(0)
    },
    selectMyLabels() {
      //Needs endpoint for this
    },
    deleteLabels() {
      if(window.confirm(`You're trying to delete this record(s). Are you sure want to proceed?`)) {
        let that = this
        this.selected.forEach((label, index) => {
          RemoveLabel(label.id).then(() => {
            this.list.splice(that.list.findIndex(item => {
              return item.id == label.id
            }),1)
          })
        })
        this.selected = []
      }
    },
    updateLabel(label) {
      console.log(label)
      UpdateLabel(label).then(response => {
        let index = this.list.findIndex(item => {
          item.id == label.id
        })
        this.list[index] = response
      })
    }
  }
}
</script>

