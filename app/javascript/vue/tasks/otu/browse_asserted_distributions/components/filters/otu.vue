<template>
  <div>
    <h3>Otu</h3>
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Search an OTU"
      param="term"
      label="label_html"
      autofocus
      :clear-after="true"
      @getItem="$emit('update:modelValue', $event.id)"
    />
  </div>
</template>

<script>
import Autocomplete from '@/components/ui/Autocomplete'
import { Otu } from '@/routes/endpoints'

export default {
  components: {
    Autocomplete
  },
  props: {
    modelValue: {
      type: [String, Number],
      default: undefined
    }
  },

  data() {
    return {
      otu: undefined
    }
  },

  mounted() {
    this.GetParams()
  },

  methods: {
    GetParams() {
      const urlParams = new URLSearchParams(window.location.search)
      const otuId = urlParams.get('otu_id')

      if (/^\d+$/.test(otuId)) {
        this.loadOtu(otuId)
      }
    },

    loadOtu(id) {
      Otu.find(id).then((response) => {
        this.otu = response.body
        this.$emit('update:modelValue', id)
      })
    }
  }
}
</script>
