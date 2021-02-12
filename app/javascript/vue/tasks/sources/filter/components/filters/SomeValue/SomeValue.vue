<template>
  <div>
    <h3>Some value in</h3>
    <select @change="addAttribute">
      <option
        selected>
        Select an attribute
      </option>
      <option
        v-for="name in filteredList"
        :key="name"
        :value="name"
        @click="addAttribute(item)">
        {{ name }}
      </option>
    </select>
    <table
      v-if="selected.length"
      class="vue-table">
      <thead>
        <tr>
          <th>Name</th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <template
          v-for="(item, index) in selected"
          class="table-entrys-list">
          <row-item
            class="list-complete-item"
            :key="index"
            :item="item"
            v-model="item.empty"
            @remove="removeAttr(index)"
          />
        </template>
      </transition-group>
    </table>
  </div>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import RowItem from '../shared/RowItem'

export default {
  components: {
    RowItem
  },
  props: {
    model: {
      type: String,
      required: true
    },
    value: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      attributes: []
    }
  },
  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },

    filteredList () {
      return this.attributes
        .map(attr => attr.name)
        .filter(attr =>
          !this.selected.find(({ name }) => name === attr)
        )
    }
  },
  async created () {
    const urlParams = URLParamsToJSON(location.href)
    this.attributes = (await AjaxCall('get', `/${this.model}/attributes`)).body

    const {
      empty = [],
      not_empty = []
    } = urlParams

    this.selected = [].concat(
      empty.map(name => ({ name, empty: true })),
      not_empty.map(name => ({ name, empty: false }))
    )
  },
  methods: {
    addAttribute (event) {
      const name = event.target.value
      if (!name) return
      this.selected.push({
        name,
        empty: false
      })
    },

    removeAttr (index) {
      this.selected.splice(index, 1)
    }
  }
}
</script>
