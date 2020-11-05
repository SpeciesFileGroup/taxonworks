<template>
  <div>
    <h2>Otus</h2>
    <autocomplete
      url="/otus/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search a OTU..."
      clear-after
      @getItem="addOtu($event.id)"
    />
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(otu, index) in otusStore"
          :key="otu.id">
          <span v-html="otu.object_tag"/>
          <span
            class="btn-delete button-circle button-default"
            @click="removeOtu(index)"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetOtu } from '../../request/resources.js'

export default {
  components: {
    Autocomplete
  },
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      otusStore: []
    }
  },
  watch: {
    otusStore (newVal) {
      this.$emit('input', newVal.map(otu => otu.id))
    }
  },
  created () {

  },
  methods: {
    removeOtu (index) {
      this.otusStore.splice(index, 1)
    },
    addOtu (id) {
      GetOtu(id).then(({ body }) => {
        this.otusStore.push(body)
      })
    }
  }
}
</script>

<style>

</style>