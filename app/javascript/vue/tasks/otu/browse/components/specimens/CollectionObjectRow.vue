<template>
  <div class="panel margin-small-bottom">
    <div
      @click="expand = !expand"
      class="cursor-pointer inline">
      <div
        :data-icon="expand ? 'w-arrow-down' : 'w-arrow-right'"
        class="expand-box button-circle button-default separate-right"/>
      <span>{{ ceLabel }}</span>
    </div>
    <template v-if="expand">
      <specimen-information
        class="species-information-container"
        v-if="expand"
        :specimen="specimen"/>
    </template>
  </div>
</template>

<script>

import SpecimenInformation from './SpecimenInformation'

export default {
  components: {
    SpecimenInformation
  },
  props: {
    specimen: {
      type: Object,
      required: true
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
<style scoped>
  .species-information-container {
    margin-left: 20px;
  }
</style>
