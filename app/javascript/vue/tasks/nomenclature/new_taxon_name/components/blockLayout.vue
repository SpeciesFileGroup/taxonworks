<template>
  <div>
    <spinner
      :show-spinner="false"
      :show-legend="false"
      v-if="spinner || !taxon.id"/>
    <div class="panel basic-information">
      <a
        v-if="anchor"
        :name="anchor"
        class="anchor"/>
      <div
        class="header flex-separate middle"
        :class="{ 'validation-warning' : warning }">
        <slot name="header">
          <h3>Default title</h3>
        </slot>
        <expand
          @changed="expanded = !expanded"
          :expanded="expanded"/>
      </div>
      <div
        class="body"
        v-if="expanded">
        <slot name="body"/>
      </div>
    </div>
  </div>
</template>

<script>
import Expand from './expand.vue'
import Spinner from 'components/spinner.vue'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    Expand,
    Spinner
  },
  props: {
    anchor: {
      type: String,
      default: undefined
    },
    spinner: {
      type: Boolean,
      default: false
    },
    warning: {
      type: [Boolean, Number, Object],
      default: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  data () {
    return {
      expanded: true
    }
  }
}
</script>
