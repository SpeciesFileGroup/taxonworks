<template>
  <div class="panel content">
    <h3>Count cutoff</h3>
    <InputRange
      v-model.number="cuttOffValue"
      min="2"
      max="100"
      step="1"
      @input:mouseup="verbatimParams.count_cutoff = cuttOffValue"
    />
  </div>
</template>

<script setup>
import useStore from '../composables/useStore'
import InputRange from '@/components/ui/Input/InputRange.vue'
import { ref } from 'vue'

const { verbatimParams } = useStore()

const cuttOffValue = ref(verbatimParams.value.count_cutoff)
</script>
