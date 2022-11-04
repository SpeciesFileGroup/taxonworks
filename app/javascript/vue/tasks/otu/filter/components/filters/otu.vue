<template>
  <div>
    <h3>Otu</h3>
    <smart-selector
      model="otus"
      target="TaxonName"
      @select="setOtu"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Otu } from 'routes/endpoints'

export default {
  components: { SmartSelector },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    otuId: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      otuSelected: undefined
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
        Otu.find(urlParams.otu_id).then(response => {
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
