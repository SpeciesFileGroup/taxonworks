<template>
  <div class="panel content panel-section">
    <h2 class="margin-remove-bottom">Scalebar</h2>
    <span>Note: Will be converted to pixels per centimeters.</span>
    <div class="horizontal-left-content margin-medium-top">
      <div class="field label-above">
        <label>Pixels</label>
        <input
          type="text"
          v-model.number="pixels"
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
          v-model.number="unitValue">
      </div>
      <div class="field label-above">
        <label>Unit</label>
        <select v-model="selected">
          <option
            v-for="(item, key) in unitToCm"
            :key="key"
            :value="item">
            {{ key }}
          </option>
        </select>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

const unitToCm = {
  mm: 1 / 10,
  cm: 1,
  nm: 1 / 1e+7,
  um: 1 / 10000,
  m: 100,
  in: 2.54,
  ft: 30.48,
  mi: 160934,
  nmi: 185200,
  P: 0.42333333
}

export default {
  computed: {
    isInputFilled () {
      return this.pixels && this.unitValue
    },
    pixelsToCm: {
      get () {
        return this.$store.getters[GetterNames.GetPixels]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPixels, value)
      }
    },
    pixelValue () {
      return this.isInputFilled ? (this.pixels / (this.unitValue * this.selected)) : null
    }
  },

  data () {
    return {
      unitToCm: unitToCm,
      selected: unitToCm.mm,
      pixels: null,
      unitValue: null
    }
  },

  watch: {
    pixelValue (newVal) {
      this.pixelsToCm = newVal
    }
  }
}
</script>
