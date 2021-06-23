<template>
  <otu-button
    :id="id"
    :taxon-name="taxonName"
    :redirect="redirect"
    :object-id="objectId"
    :klass="klass"
  />
</template>
<script>

import OtuButton from 'components/otu/otu.vue'

export default {
  components: { OtuButton },

  props: {
    id: {
      type: String,
      required: true
    },

    objectId: {
      type: String,
      required: true
    },

    taxonName: {
      type: String,
      required: true
    },

    redirect: {
      type: Boolean,
      required: true
    },

    klass: {
      type: String,
      default: ''
    }
  }
}
</script>
