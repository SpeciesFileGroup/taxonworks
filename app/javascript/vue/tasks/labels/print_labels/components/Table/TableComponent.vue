<template>
  <div>
    <option-buttons/>
    <table>
      <thead>
        <tr>
          <th>Select</th>
          <th>Label</th>
          <th>Edit</th>
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
          <td v-html="item.text"/>
          <td>
            <button
              type="button"
              class="button circle-button btn-edit"/>
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
import { GetLabels } from '../../request/resources.js'

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
    GetLabels().then(response => {
      this.list = response
    })
  }
}
</script>

