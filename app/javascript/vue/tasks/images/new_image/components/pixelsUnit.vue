<template>
  <div class="panel content panel-section">
    <h2 class="margin-remove-bottom">Scalebar</h2>
    <span>Note: Will be converted to pixels per centimeters.</span>
    <div class="horizontal-left-content margin-medium-top">
      <div class="field label-above">
        <label>Pixels</label>
        <input
          type="text"
          v-model="pixels"
          @input="pixelsToUnit"
        >
      </div>
      <div class="field margin-small-left margin-small-right label-above">
        <label class="label-above">&nbsp;</label>
        <label class="label-above">=</label>
      </div>
      <div class="field label-above">
        <label>Value</label>
        <input
          type="text"
          @input="unitToPixels"
          v-model="unitValue">
      </div>
      <div class="field label-above">
        <label>Unit</label>
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

const pxToUnits = {
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
}

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
      pxToUnits: pxToUnits,
      selected: pxToUnits.mm,
      pixels: null,
      unitValue: null,
      isUnitLastSet: false
    }
  },
  watch: {
    pixelValue (newVal) {
      this.pixelsToCm = this.pixels ? this.pixels * this.pxToUnits.cm : null
    },
    selected () {
      if (this.isUnitLastSet) {
        this.unitToPixels()
      } else {
        this.pixelsToUnit()
      }
    }
  },
  methods: {
    apply () {
      this.$store.dispatch(ActionNames.ApplyPixelToCentimeter)
    },
    pixelsToUnit () {
      this.isUnitLastSet = false
      this.unitValue = this.pixelValue
    },
    unitToPixels () {
      this.isUnitLastSet = true
      this.pixels = this.unitValue ? this.unitValue / this.selected : null
    }
  }
}
</script>
