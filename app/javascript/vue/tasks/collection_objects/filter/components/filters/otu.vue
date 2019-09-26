<template>
  <div>
    <h2>Determinations</h2>
    <h3>Otu</h3>
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Select an otu"
      param="term"
      label="label_html"
      :clear-after="true"
      display="label"
      @getItem="addOtu" />
    <div class="field separate-top">
      <label>
        <input
          v-model="otus.otu_descendants"
          type="checkbox">
        Include descendants (if available)
      </label>
    </div>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(otu, index) in otusStore"
          :key="otu.id">
          <span v-html="otu.label_html"/>
          <span
            class="btn-delete button-circle"
            @click="removeOtu(index)"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    otus: {
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
      otusStore: []
    }
  },
  watch: {
    otus: {
      handler (newVal) {
        if (!newVal.otu_ids.length) {
          this.otusStore = []
        }
      },
      deep: true
    }
  },
  methods: {
    removeOtu (index) {
      this.otus.otu_ids.splice(index, 1)
      this.otusStore.splice(index, 1)
    },
    addOtu (item) {
      this.otus.otu_ids.push(item.id)
      this.otusStore.push(item)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
