<template>
  <div>
    <h3>Otu</h3>
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Search an OTU"
      param="term"
      label="label_html"
      :clear-after="true"
      @getItem="$emit('input', $event.id)"/>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetOtu } from '../../request/resources'

export default {
  components: {
    Autocomplete
  },
  props: {
    value: {
      type: [String, Number],
      default: undefined
    },
  },
  data () { 
    return {
      otu: undefined
    }
  },
  mounted () {
    this.GetParams()
  },
  methods: {
    GetParams () {
      const urlParams = new URLSearchParams(window.location.search)
      const otuId = urlParams.get('otu_id')

      if ((/^\d+$/).test(otuId)) {
        this.loadOtu(otuId)
      }
    },
    loadOtu (id) {
      GetOtu(id).then(response => {
        this.otu = response.body
        this.$emit('input', id)
      })
    }
  }
}
</script>