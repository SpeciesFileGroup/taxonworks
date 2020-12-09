<template>
  <div class="content">
    <span><span v-html="`${type.type_type} of ${type.original_combination}`"/> | <a :href="urlType">Edit</a></span>
    <ul>
      <li>
        <span>Citation: <b><span v-html="citationsLabel"/></b></span>
      </li>
    </ul>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'
import { GetterNames } from '../../store/getters/getters'

export default {
  props: {
    type: {
      type: Object,
      required: true
    }
  },
  computed: {
    citationsLabel () {
      return this.type.origin_citation ? this.type.origin_citation.source.object_tag : 'not specified'
    },
    otu () {
      return this.$store.getters[GetterNames.GetCurrentOtu]
    },
    urlType () {
      return `${RouteNames.TypeMaterial}?taxon_name_id=${this.otu.taxon_name_id}&type_material_id=${this.type.id}`
    }
  }
}
</script>
