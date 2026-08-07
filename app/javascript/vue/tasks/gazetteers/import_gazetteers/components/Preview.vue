<template>
  <BlockLayout
    expand
  >
    <template #header>
      <div class="header">
        <h3>Shapefile data preview</h3>
      </div>
    </template>

    <template #body>
      <div class="table_container">
        <p>
          There are {{ data.records_count }}
          records{{ overflowWarningIfNeeded }}.
        </p>
        <p>
          Each record lists the Count of how many total records have that name,
          with highest counts listed first.
        </p>
        <p v-if="invalidAlphasExist">
          There are invalid alpha values below, highlighted in
          <span class="invalid_alpha">RED</span>; <b>these alpha values will be
          silently dropped on import</b>.
        </p>
        <table
          v-if="data.text_values?.length > 0"
          class="vue-table table-striped shp-table"
        >
          <thead>
            <tr>
              <th
                v-for="(v, k) in data.text_fields_hash"
                :key="k"
              >
                {{ columnForDisplay(k, v) }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="a in data.text_values"
            >
              <td v-for="(v, i) in a">
                <template v-if="i < 3">
                  {{ v }}
                </template>
                <span
                  v-else
                  :class="{'invalid_alpha': invalidAlpha(columns[i], v)}"
                >
                 {{ v }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { computed, ref, watch } from 'vue'

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
})

// Some record has an a2 or a3 value that is not valid.
const invalidAlphasExist = ref(false)

const overflowWarningIfNeeded = computed(() => {
  if (props.data.records_count > props.data.max_values_count) {
    return `, but only the first ${props.data.max_values_count} records have been processed for this preview`
  }
})

const columns = computed(() => {
  return Object.keys(props.data.text_fields_hash)
})

watch(() => props.data,
  () => {
    invalidAlphasExist.value = false

    props.data.text_values.sort(
      // Sort by the # of records a given name appears in, then alphabetically
      (a, b) => {
        const countDiff = b[2] - a[2] // counts
        if (countDiff == 0) {
          const nameDiff = a[1].localeCompare(b[1]) // names
          if (nameDiff == 0) {
            return a[0] - b[0] // record numbers
          }
          return nameDiff
        }
        return countDiff
      }
    )
  },
  { immediate: true }
)

function invalidAlpha(whichAlpha, value) {
  if (!value) return false

  const re = whichAlpha == 'a2' ? /^[A-Z][A-Z]$/ : /^[A-Z][A-Z][A-Z]$/
  if (re.test(value.toUpperCase())) {
    return false
  } else {
    invalidAlphasExist.value = true
    return true
  }
}

function columnForDisplay(abstract, specific) {
  const a = (abstract.charAt(0).toUpperCase() + abstract.slice(1))
    .replace('_', ' ')
  return specific ? `${a} (${specific})` : a
}

</script>

<style lang="scss" scoped>
.shp-table {
  width: 600px;
}

.table_container {
  max-height: 800px;
  overflow-y: auto;
  width: calc(600px + 2em); // room for vertical scrollbar
}

.invalid_alpha {
  color: red;
}
</style>