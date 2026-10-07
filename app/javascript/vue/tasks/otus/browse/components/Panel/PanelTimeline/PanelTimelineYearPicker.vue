<template>
  <div class="year-box">
    <ul class="no_bullets">
      <li
        v-for="(_, year) in years"
        class="full_width year-line"
        :key="year"
        @click="() => (currentYear = Number(year))"
      >
        <VBtn
          class="year-string"
          :color="currentYear === Number(year) ? 'default' : 'primary'"
          @click.stop="
            () =>
              (currentYear =
                currentYear === Number(year) ? undefined : Number(year))
          "
        >
          {{ year }}
        </VBtn>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  years: {
    type: Object,
    required: true
  }
})

const currentYear = defineModel({
  type: Number,
  default: undefined
})

const max = ref()

watch(
  () => props.years,
  (newVal) => {
    max.value = Math.max(...Object.values(newVal))
  },
  { immediate: true }
)
</script>

<style scoped>
.year-box {
  overflow-y: scroll;
  overflow-x: hidden;
  max-height: 450px;
}
.year-line {
  margin: 4px;
  border-radius: 4px;
  padding-right: 4px;
  cursor: pointer;
}
</style>
