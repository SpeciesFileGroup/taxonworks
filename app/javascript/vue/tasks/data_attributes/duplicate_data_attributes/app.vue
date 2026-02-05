<template>
  <div class="task-container">
    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Loading duplicates..."
    />

    <div
      v-if="!hasQueryParam && !isLoading"
      class="panel content middle"
    >
      <p>
        This task is accessed via the radial linker from a Filter result. No
        filter query was provided.
      </p>
    </div>

    <div
      v-if="hasQueryParam && !hasData && !isLoading"
      class="panel content middle"
    >
      <p>No duplicate predicates were found in the filtered results.</p>
    </div>

    <template v-if="hasData">
      <NavBar>
        <div class="flex-separate middle">
          <span class="separate-right"
            >Total objects with duplicates:
            {{ data.total_objects_with_duplicates }}</span
          >
        </div>
      </NavBar>

      <table class="table-striped full_width">
        <thead>
          <tr>
            <th
              class="w-4"
              @click="sortBy('object_tag')"
            >
              Object
              <span v-if="sortColumn === 'object_tag'">{{
                sortAscending ? '&uarr;' : '&darr;'
              }}</span>
            </th>
            <th class="w-2">Predicate</th>
            <th class="w-3">Value</th>
            <th
              class="w-2"
              @click="sortBy('creator_name')"
            >
              Creator
              <span v-if="sortColumn === 'creator_name'">{{
                sortAscending ? '&uarr;' : '&darr;'
              }}</span>
            </th>
            <th
              class="w-2"
              @click="sortBy('updater_name')"
            >
              Updater
              <span v-if="sortColumn === 'updater_name'">{{
                sortAscending ? '&uarr;' : '&darr;'
              }}</span>
            </th>
            <th
              class="w-2"
              @click="sortBy('updated_at')"
            >
              Updated
              <span v-if="sortColumn === 'updated_at'">{{
                sortAscending ? '&uarr;' : '&darr;'
              }}</span>
            </th>
            <th class="w-2"></th>
          </tr>
        </thead>
        <tbody>
          <template
            v-for="object in sortedObjects"
            :key="object.id"
          >
            <tr class="object-header-row">
              <td
                colspan="6"
                v-html="object.object_tag"
              />
              <td class="radial-cell">
                <div class="horizontal-right-content gap-small">
                  <RadialNavigator :global-id="object.global_id" />
                  <RadialAnnotator :global-id="object.global_id" />
                </div>
              </td>
            </tr>
            <tr
              v-for="da in object.data_attributes"
              :key="da.id"
              :class="{
                'exact-duplicate': da.is_exact_duplicate
              }"
            >
              <td></td>
              <td>
                <span v-html="da.object_tag" />
                >
              </td>
              <td>
                <textarea
                  v-model="da.value"
                  class="value-input"
                  :rows="calculateRows(da.value)"
                  @blur="() => saveDataAttribute(da)"
                  @keydown="(e) => handleKeydown(e, da)"
                  @input="(e) => autoResize(e.target)"
                />
              </td>
              <td>{{ da.creator_name }}</td>
              <td>{{ da.updater_name }}</td>
              <td>{{ formatDate(da.updated_at) }}</td>
              <td class="radial-cell">
                <VBtn
                  color="destroy"
                  circle
                  title="Delete data attribute"
                  @click="() => destroyDataAttribute(object, da)"
                >
                  <VIcon
                    name="trash"
                    x-small
                  />
                </VBtn>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </template>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref } from 'vue'
import { useQueryParam } from '../field_synchronize/composables'
import { DataAttribute } from '@/routes/endpoints'
import { removeFromArray } from '@/helpers'
import ajaxCall from '@/helpers/ajaxCall'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import NavBar from '@/components/layout/NavBar.vue'

defineOptions({
  name: 'DuplicateDataAttributes'
})

const { queryParam, queryValue } = useQueryParam()

const isLoading = ref(false)
const data = ref({ objects: [], total_objects_with_duplicates: 0 })
const sortColumn = ref(null)
const sortAscending = ref(true)
const originalValues = ref({})

const hasQueryParam = computed(() => !!queryParam.value)
const hasData = computed(() => data.value.objects.length > 0)

const sortedObjects = computed(() => {
  if (!sortColumn.value) {
    return data.value.objects
  }

  const objects = [...data.value.objects]

  if (sortColumn.value === 'object_tag') {
    objects.sort((a, b) => {
      const aVal = a.object_tag || ''
      const bVal = b.object_tag || ''
      return sortAscending.value
        ? aVal.localeCompare(bVal)
        : bVal.localeCompare(aVal)
    })
  } else {
    objects.sort((a, b) => {
      const aFirst = a.data_attributes[0]
      const bFirst = b.data_attributes[0]
      const aVal = aFirst?.[sortColumn.value] || ''
      const bVal = bFirst?.[sortColumn.value] || ''

      if (sortColumn.value === 'updated_at') {
        return sortAscending.value
          ? new Date(aVal) - new Date(bVal)
          : new Date(bVal) - new Date(aVal)
      }

      return sortAscending.value
        ? String(aVal).localeCompare(String(bVal))
        : String(bVal).localeCompare(String(aVal))
    })
  }

  return objects
})

function sortBy(column) {
  if (sortColumn.value === column) {
    sortAscending.value = !sortAscending.value
  } else {
    sortColumn.value = column
    sortAscending.value = true
  }
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
}

const CHARS_PER_ROW = 60

function calculateRows(value) {
  if (!value) return 1

  // Calculate wrapped lines based on character length
  const lines = value.split('\n')
  const wrappedLines = lines.reduce((total, line) => {
    return total + Math.max(1, Math.ceil(line.length / CHARS_PER_ROW))
  }, 0)

  return Math.max(1, wrappedLines)
}

function autoResize(textarea) {
  // Reset height to recalculate
  textarea.style.height = 'auto'
  textarea.style.height = textarea.scrollHeight + 'px'
}

function handleKeydown(event, da) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    saveDataAttribute(da)
    event.target.blur()
  }
}

async function saveDataAttribute(da) {
  const originalValue = originalValues.value[da.id]
  if (originalValue === da.value) {
    return
  }

  try {
    const response = await DataAttribute.update(da.id, {
      data_attribute: { value: da.value }
    })

    originalValues.value[da.id] = da.value

    da.updated_at = response.body.updated_at
    da.updater_name = response.body.updater?.name

    TW.workbench.alert.create('Data attribute updated successfully.', 'notice')
  } catch (error) {
    da.value = originalValue
  }
}

function pulseElement(element) {
  if (!element) return
  element.classList.add('pulse-success')
  setTimeout(() => {
    element.classList.remove('pulse-success')
  }, 1000)
}

function hasDuplicatePredicates(arr) {
  const seen = new Set()

  for (const item of arr) {
    const key = item.predicate_name

    if (seen.has(key)) {
      return true
    }

    seen.add(key)
  }

  return false
}

async function destroyDataAttribute(object, da) {
  if (!confirm('Are you sure you want to delete this data attribute?')) {
    return
  }

  try {
    await DataAttribute.destroy(da.id)

    removeFromArray(object.data_attributes, da)

    if (!hasDuplicatePredicates(object.data_attributes)) {
      removeFromArray(data.value.objects, object)
      data.value.total_objects_with_duplicates--
    }

    TW.workbench.alert.create('Data attribute deleted successfully.', 'notice')
  } catch (error) {
    // Error handled by ajaxCall
  }
}

async function loadDuplicates() {
  if (!queryParam.value) {
    return
  }

  isLoading.value = true

  try {
    const response = await ajaxCall(
      'post',
      '/tasks/data_attributes/duplicate_data_attributes/data',
      { [queryParam.value]: queryValue.value }
    )

    data.value = response.body

    data.value.objects.forEach((obj) => {
      obj.data_attributes.forEach((da) => {
        originalValues.value[da.id] = da.value
      })
    })
  } catch (error) {
    TW.workbench.alert.create(
      'Failed to load duplicate data attributes.',
      'error'
    )
  } finally {
    isLoading.value = false
  }
}

onBeforeMount(() => {
  loadDuplicates()
})
</script>

<style scoped>
.task-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 1rem;
}

table {
  border-collapse: collapse;
}

th {
  cursor: pointer;
  user-select: none;
  text-align: left;
  padding: 8px;
  position: sticky;
  top: 0;
  background-color: var(--color-menu-background);
  color: var(--color-menu-foreground);
  z-index: 10;
}

th:hover {
  background-color: var(--color-menu-highlight);
}

td {
  padding: 8px;
  vertical-align: middle;
}

.object-header-row {
  background-color: var(--color-menu-background);
  font-weight: bold;
}

.object-header-row td:first-child {
  padding-left: 8px;
}

.exact-duplicate {
  background-color: var(--color-caution) !important;
}

.predicate-tag {
  display: inline-block;
}

.value-input {
  min-width: 60ch;
  text-align: left;
  resize: vertical;
  min-height: 24px;
  font-family: inherit;
  font-size: inherit;
}

.radial-cell {
  text-align: right;
  white-space: nowrap;
}

.pulse-success {
  animation: pulse 0.5s ease-in-out;
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(40, 167, 69, 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(40, 167, 69, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(40, 167, 69, 0);
  }
}
</style>
