<template>
  <div>
    <h2>Otu</h2>
    <smart-selector
      model="otus"
      target="TaxonName"
      @select="setOtu"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetOtu } from '../../request/resources'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    otuId: {
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
      otuSelected: undefined,
    }
  },
  watch: {
    otuId: {
      handler (newVal) {
        if (!newVal) {
          this.removeOtu()
        }
      }
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      if (urlParams.otu_id) {
        GetOtu(urlParams.otu_id).then(response => {
          this.setOtu(response.body)
        })
      }
    }
  },
  methods: {
    setOtu (value) {
      this.otu = value
    },
    removeOtu () {
      this.otuSelected = undefined
    }
  }
}
</script>
