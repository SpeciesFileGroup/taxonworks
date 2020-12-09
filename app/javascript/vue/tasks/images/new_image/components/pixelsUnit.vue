<template>
  <div class="panel content panel-section">
    <h2>Pixels to centimeters</h2>
    <div class="horizontal-left-content">
      <div class="field label-above">
        <label>Pixels</label>
        <input
          type="text"
          v-model="pixels"
        >
      </div>
      <div class="field margin-small-left margin-small-right label-above">
        <label class="label-above">&nbsp;</label>
        <label class="label-above">=</label>
      </div>
      <div class="field label-above">
        <label>&nbsp;</label>
        <input
          type="text"
          :value="pixelValue"
          disabled>
      </div>
      <div class="field label-above">
        <label>&nbsp;</label>
        <select v-model="selected">
          <option
            v-for="(item, key) in pxToUnits"
            :key="key"
            :value="item">
            {{ key }}
          </option>
        </select>
      </div>
      <div class="field label-above">
        <label>&nbsp;</label>
        <button
          class="button normal-input button-submit margin-small-left"
          type="button"
          @click="apply"
        >
          Apply
        </button>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

export default {
  computed: {
    pixelsToCm: {
      get () {
        return this.$store.getters[GetterNames.SetPixels]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPixels, value)
      }
    },
    pixelValue () {
      return this.pixels && this.selected ? this.pixels * this.selected : null
    }
  },
  data () {
    return {
      pxToUnits: {
        mm: 0.2645833333,
        cm: 0.0264583333,
        um: 264.5833,
        nm: 264583.3,
        m: 0.0002645833,
        in: 0.0104166667,
        ft: 0.0008680556,
        mi: 1.6440444056709E-7,
        nmi: 1.4286355291577E-7,
        P: 0.062499992175197
      },
      selected: undefined,
      pixels: null
    }
  },
  watch: {
    pixelValue (newVal) {
      this.pixelsToCm = this.pixels ? this.pixels * this.pxToUnits.cm : null
    }
  },
  methods: {
    apply () {
      this.$store.dispatch(ActionNames.ApplyPixelToCentimeter)
    }
  }
}
</script>
