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
    <display-list
      :list="selected"
      :delete-warning="false"
      delete
      @deleteIndex="removeAttr"
    />
  </div>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import DisplayList from 'components/displayList'

export default {
  components: {
    DisplayList
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
      return this.attributes.map(attr => attr.name).filter(name => !this.selected.includes(name))
    }
  },
  async created () {
    this.attributes = (await AjaxCall('get', `/${this.model}/attributes`)).body
  },
  methods: {
    addAttribute (event) {
      const name = event.target.value
      if (!name) return
      this.selected.push(name)
    },
    removeAttr (index) {
      this.selected.splice(index, 1)
    }
  }
}
</script>
