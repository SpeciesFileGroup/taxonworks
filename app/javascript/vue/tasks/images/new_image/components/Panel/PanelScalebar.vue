<template>
  <BlockLayout>
    <template #header>
      <h3>Scalebar</h3>
    </template>
    <template #body>
      <span>Note: Will be converted to pixels per centimeters.</span>
      <div class="horizontal-left-content margin-medium-top">
        <div class="field label-above">
          <label>Pixels</label>
          <input
            type="text"
            v-model.number="pixels"
          />
        </div>
        <div class="field margin-small-left margin-small-right label-above">
          <label class="label-above">&nbsp;</label>
          <label class="label-above">=</label>
        </div>
        <div class="field label-above">
          <label>Value</label>
          <input
            type="text"
            v-model.number="unitValue"
          />
        </div>
        <div class="field label-above">
          <label>Unit</label>
          <select v-model="selected">
            <option
              v-for="(item, key) in unitToCm"
              :key="key"
              :value="item"
            >
              {{ key }}
            </option>
          </select>
        </div>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const unitToCm = {
  mm: 1 / 10,
  cm: 1,
  nm: 1 / 1e7,
  um: 1 / 10000,
  m: 100,
  in: 2.54,
  ft: 30.48,
  mi: 160934,
  nmi: 185200,
  P: 0.42333333
}

const store = useStore()

const pixels = ref(null)
const unitValue = ref(null)
const selected = ref(unitToCm.mm)

const isInputFilled = computed(() => pixels.value && unitValue.value)
const pixelsToCm = computed({
  get() {
    return store.getters[GetterNames.GetPixels]
  },
  set(value) {
    store.commit(MutationNames.SetPixels, value)
  }
})

const pixelValue = computed(() => {
  return isInputFilled.value
    ? pixels.value / (unitValue.value * selected.value)
    : null
})

watch(pixelValue, (newVal) => {
  pixelsToCm.value = newVal
})
</script>
