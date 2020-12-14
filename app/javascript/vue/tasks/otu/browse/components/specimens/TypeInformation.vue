<template>
  <div>
    <div
      @click="expand = !expand"
      class="cursor-pointer inline">
      <div
        :data-icon="expand ? 'w_less' : 'w_plus'"
        class="expand-box button-default separate-right"/>
      <span>[<span v-html="types.map(type => `${type.type_type} of ${type.original_combination}`).join('; ')"/>] <span>{{ ceLabel }}</span></span>
    </div>
    <template v-if="expand">
      <type-data
        v-for="type in types"
        :key="type.id"
        :type="type"/>
      <specimen-information
        v-if="expand"
        :specimen="specimen"/>
    </template>
  </div>
</template>

<script>

import SpecimenInformation from './SpecimenInformation'
import TypeData from './TypeData'

export default {
  components: {
    SpecimenInformation,
    TypeData
  },
  props: {
    specimen: {
      type: Object,
      required: true
    },
    types: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    ceLabel () {
      const levels = ['country', 'stateProvince', 'county', 'verbatimLocality']
      const tmp = []
      levels.forEach(item => {
        if (this.specimen[item]) { tmp.push(this.specimen[item]) }
      })
      return tmp.join(', ')
    }
  },
  data () {
    return {
      expand: false
    }
  }
}
</script>
