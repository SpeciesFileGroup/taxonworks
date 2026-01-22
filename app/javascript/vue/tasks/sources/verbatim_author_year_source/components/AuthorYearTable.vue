<template>
  <table class="full_width table-striped">
    <thead>
      <tr>
        <th @click="sortBy('verbatim_author')">
          Author
          <span v-if="sortColumn === 'verbatim_author'">
            {{ sortDirection === 'asc' ? '▲' : '▼' }}
          </span>
        </th>
        <th @click="sortBy('year_of_publication')">
          Year
          <span v-if="sortColumn === 'year_of_publication'">
            {{ sortDirection === 'asc' ? '▲' : '▼' }}
          </span>
        </th>
        <th>Copy</th>
        <th @click="sortBy('record_count')">
          Count
          <span v-if="sortColumn === 'record_count'">
            {{ sortDirection === 'asc' ? '▲' : '▼' }}
          </span>
        </th>
        <th>New Source</th>
        <th>Filter</th>
        <th>Taxon names</th>
        <th>Batch Cite</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="row in sortedData"
        :key="`${row.verbatim_author}-${row.year_of_publication}`"
        :data-author="row.verbatim_author"
        :data-year="row.year_of_publication"
      >
        <td>{{ row.verbatim_author }}</td>
        <td>{{ row.year_of_publication }}</td>
        <td class="copy-cell">
          <ButtonClipboard
            :text="[row.verbatim_author, row.year_of_publication].join(' ')"
          />
        </td>
        <td
          class="count-cell"
          :style="{
            backgroundColor: row.heat_color,
            color: textColorFromHSL(row.heat_color)
          }"
        >
          {{ row.record_count }}
        </td>
        <td>
          <a
            :href="newSourceUrl"
            target="_blank"
          >
            New Source
          </a>
        </td>
        <td>
          <a
            :href="filterUrl(row.verbatim_author, row.year_of_publication)"
            target="_blank"
          >
            Filter TaxonNames
          </a>
        </td>
        <td>
          <VBtn
            color="primary"
            medium
            @click="
              $emit('preview', row.verbatim_author, row.year_of_publication)
            "
          >
            Taxon names
          </VBtn>
        </td>
        <td class="batch-cite-cell">
          <VBtn
            v-if="!row.isCited && !row.isPending"
            color="primary"
            medium
            @click="$emit('cite', row.verbatim_author, row.year_of_publication)"
          >
            Cite
          </VBtn>
          <div
            v-else-if="row.isPending"
            class="progress-container"
          >
            <span class="pending-text">
              {{
                row.pendingStage === 'citations'
                  ? 'Creating citations...'
                  : 'Updating taxon name authors...'
              }}
            </span>
            <div
              v-if="row.progressTotal > 0"
              class="progress-bar"
            >
              <div
                class="progress-fill"
                :style="{
                  width: `${(row.progressCurrent / row.progressTotal) * 100}%`
                }"
              />
            </div>
            <span
              v-if="row.progressTotal > 0"
              class="progress-text"
            >
              {{ row.progressCurrent }} / {{ row.progressTotal }}
            </span>
          </div>
          <span
            v-else
            class="completed-text"
          >
            ✓ Complete
          </span>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { ref, computed } from 'vue'
import { RouteNames } from '@/routes/routes'
import useStore from '../store/store'
import VBtn from '@/components/ui/VBtn/index.vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'

const store = useStore()

const sortColumn = ref('year_of_publication')
const sortDirection = ref('desc')

defineEmits(['cite', 'preview'])

const sortedData = computed(() => {
  const data = [...store.authorYearData]

  data.sort((a, b) => {
    let aVal = a[sortColumn.value]
    let bVal = b[sortColumn.value]

    // Handle null/undefined
    if (aVal == null && bVal == null) return 0
    if (aVal == null) return 1
    if (bVal == null) return -1

    // Compare values
    if (aVal < bVal) return sortDirection.value === 'asc' ? -1 : 1
    if (aVal > bVal) return sortDirection.value === 'asc' ? 1 : -1
    return 0
  })

  return data
})

const newSourceUrl = computed(() => {
  return RouteNames.NewSource
})

function sortBy(column) {
  if (sortColumn.value === column) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortColumn.value = column
    sortDirection.value = 'asc'
  }
}

function filterUrl(author, year) {
  const params = new URLSearchParams({
    author: author,
    author_exact: true,
    year_of_publication: year
  })
  return `${RouteNames.FilterNomenclature}?${params.toString()}`
}

function textColorFromHSL(hsl) {
  const match = hsl.match(/hsl\(\s*\d+\s*,\s*\d+%\s*,\s*(\d+)%\s*\)/i)
  if (!match) return '#000'

  const lightness = parseInt(match[1], 10)

  return lightness > 60 ? '#000' : '#fff'
}
</script>

<style scoped>
table {
  border-collapse: collapse;
}

th {
  cursor: pointer;
  user-select: none;
  text-align: left;
}

.copy-cell {
  text-align: center;
}

.count-cell {
  color: white;
  font-weight: bold;
  text-align: center;
}

.progress-container {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 180px;
}

.pending-text {
  color: var(--text-muted-color);
  font-style: italic;
  font-size: 0.9em;
}

.progress-bar {
  height: 6px;
  background-color: var(--border-color);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background-color: var(--color-primary);
  transition: width 0.2s ease;
}

.progress-text {
  font-size: 0.8em;
  color: var(--text-muted-color);
}

.completed-text {
  color: var(--text-muted-color);
}
</style>
