<template>
  <div>
    <div class="horizontal-left-content middle gap-small">
      <h3>{{ title }}</h3>
      <ButtonClipboard
        :text="sampleTsv"
        title="Copy the header row and example rows, tab separated"
      />
    </div>
    <slot />
    <div class="sample-scroll">
      <table class="table-striped">
        <thead>
          <tr v-if="hasGroupLabels">
            <th
              v-for="(group, i) in groups"
              :key="i"
              :colspan="group.fields.length"
              class="subtle"
            >
              {{ group.label }}
            </th>
          </tr>
          <tr>
            <th
              v-for="field in fields"
              :key="field"
              :title="help[field]"
            >
              {{ field }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(row, i) in rows"
            :key="i"
          >
            <td
              v-for="field in fields"
              :key="field"
            >
              {{ row[field] }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
// An example input table for a batch load task: the recognized column
// names as headers (optionally grouped under labels such as "required"),
// a few example rows, and a button that copies it all as TSV. Text about
// the columns goes in the default slot, between the title and the table.
import { computed } from 'vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'

const props = defineProps({
  // [{ label, fields: [column name, ...] }, ...], in column order
  groups: {
    type: Array,
    required: true
  },

  // [{ [column name]: value, ... }, ...]
  rows: {
    type: Array,
    default: () => []
  },

  // { [column name]: tooltip text }
  help: {
    type: Object,
    default: () => ({})
  },

  title: {
    type: String,
    default: 'Example'
  }
})

const fields = computed(() => props.groups.flatMap((g) => g.fields))

const hasGroupLabels = computed(() => props.groups.some((g) => g.label))

const sampleTsv = computed(() =>
  [
    fields.value.join('\t'),
    ...props.rows.map((row) => fields.value.map((f) => row[f] || '').join('\t'))
  ].join('\n')
)
</script>

<style scoped>
.sample-scroll {
  overflow-x: auto;
}
</style>
