<template>
  <div class="flex-row gap-small">
    <div class="w-min">
      <label class="label-above">Day</label>
      <input
        type="number"
        v-model="source.day"
        @change="() => (source.isUnsaved = true)"
      />
    </div>

    <div class="w-min">
      <label
        class="label-above"
        v-help.section.BibTeX.month
        >Month
      </label>
      <select
        class="normal-input"
        v-model="source.month"
        @change="() => (source.isUnsaved = true)"
      >
        <option :value="null" />
        <option
          v-for="month in months"
          :value="month.substring(0, 3).toLowerCase()"
          :key="month"
        >
          {{ month }}
        </option>
      </select>
    </div>

    <div class="w-min">
      <label
        class="label-above"
        v-help.section.BibTeX.year
        >Year
      </label>
      <input
        type="number"
        v-model="source.year"
        @change="() => (source.isUnsaved = true)"
      />
    </div>

    <div>
      <label
        class="label-above"
        v-help.section.BibTeX.yearSuffix
        >Year suffix</label
      >
      <input
        type="text"
        v-model="source.year_suffix"
        @change="() => (source.isUnsaved = true)"
      />
    </div>

    <div>
      <label
        class="d-block line-nowrap"
        v-help.section.BibTeX.yearStated
      >
        Stated year
      </label>
      <input
        type="number"
        v-model="source.stated_year"
        @change="() => (source.isUnsaved = true)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const source = defineModel({
  type: Object,
  required: true
})

const months = ref([
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
])
</script>

<style scoped>
input[type='number'] {
  width: 70px;
}
</style>
