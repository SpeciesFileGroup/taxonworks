<template>
  <div class="horizontal-left-content align-end">
    <DateFields
      v-model:year="date.year_made"
      v-model:month="date.month_made"
      v-model:day="date.day_made"
    />
    <div class="horizontal-left-content align-end margin-small-left">
      <DateNow
        v-model:year="date.year_made"
        v-model:month="date.month_made"
        v-model:day="date.day_made"
      />
      <VBtn
        type="button"
        class="button normal-input button-default margin-small-left"
        @click="setYear"
      >
        This year
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import DateFields from '@/components/ui/Date/DateFields.vue'
import DateNow from '@/components/ui/Date/DateToday.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const date = defineModel({
  type: Object,
  required: true
})

function setYear() {
  date.value.day_made = undefined
  date.value.month_made = undefined
  date.value.year_made = new Date().getFullYear()
}
</script>
