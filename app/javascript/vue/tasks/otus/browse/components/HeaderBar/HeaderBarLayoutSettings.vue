<template>
  <VModal
    :container-style="{ width: '720px' }"
    @close="emit('close')"
  >
    <template #header>
      <h3>Layout settings</h3>
    </template>
    <template #body>
      <div class="field label-above">
        <label>Layout</label>
        <VSwitch
          v-model="currentPresetLabel"
          :options="presetLabels"
        />
      </div>

      <div class="field separate-bottom">
        <label>
          <input
            type="checkbox"
            :checked="!!taskPreferences?.hideEmptyPanels"
            @change="toggleHideEmptyPanels"
          />
          Hide panels without data
        </label>
      </div>

      <p class="subtle separate-bottom">
        Drag panels to reorder them or to move them between rows and columns.
      </p>

      <div class="flex-col gap-medium">
        <div
          v-for="(row, rowIndex) in rows"
          :key="rowIndex"
          class="layout-row"
        >
          <div class="flex-separate middle margin-small-bottom">
            <b>Row {{ rowIndex + 1 }}</b>
            <div class="horizontal-left-content gap-small">
              <VBtn
                color="primary"
                variant="tonal"
                @click="toggleSplit(rowIndex)"
              >
                {{ row.columns.length > 1 ? 'Merge columns' : 'Split in two' }}
              </VBtn>
              <VBtn
                v-if="rows.length > 1"
                color="primary"
                variant="tonal"
                @click="removeRow(rowIndex)"
              >
                Remove row
              </VBtn>
            </div>
          </div>

          <div
            class="layout-columns gap-medium"
            :class="{ 'layout-columns--split': row.columns.length > 1 }"
          >
            <VDraggable
              v-for="(column, columnIndex) in row.columns"
              :key="columnIndex"
              class="layout-column panel"
              :class="{ 'layout-column--empty': !column.length }"
              group="browse-otu-panels"
              handle=".handle"
              :model-value="column"
              :item-key="(element) => element"
              @update:model-value="
                (value) => updateColumn(rowIndex, columnIndex, value)
              "
              @end="syncRows"
            >
              <template #item="{ element }">
                <div>
                  <label class="handle cursor-grab">
                    <input
                      type="checkbox"
                      :checked="sections.includes(element)"
                      @change="toggleSection(element)"
                    />
                    {{ PANEL_COMPONENTS[element]?.title }}
                  </label>
                </div>
              </template>
            </VDraggable>
          </div>
        </div>

        <div>
          <VBtn
            color="primary"
            variant="tonal"
            @click="addRow"
          >
            Add row
          </VBtn>
        </div>
      </div>
    </template>
    <template #footer>
      <VBtn
        color="primary"
        @click="reset"
      >
        Reset
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import {
  PANEL_COMPONENTS,
  DEFAULT_PREFERENCES,
  LAYOUT_OPTIONS,
  LAYOUT_CUSTOM
} from '../../constants'
import {
  arrangementForLayout,
  cloneRows,
  flattenRows
} from '../../utils/resolveLayoutRows.js'
import { useUserPreferences } from '@/composables'
import { copyObject } from '@/helpers'
import VModal from '@/components/ui/Modal.vue'
import VDraggable from 'vuedraggable'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSwitch from '@/components/ui/VSwitch.vue'

const props = defineProps({
  preferences: {
    type: Object,
    required: true
  },

  storageKey: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['close'])

const { setPreference } = useUserPreferences()

const presetLabels = LAYOUT_OPTIONS.map(({ label }) => label)

const taskPreferences = computed(
  () => props.preferences?.layout?.[props.storageKey]
)

const sections = computed(() => taskPreferences.value?.sections || [])

const rows = ref(arrangementForLayout(taskPreferences.value))

const currentPresetLabel = computed({
  get() {
    const option = LAYOUT_OPTIONS.find(
      ({ value }) => value === taskPreferences.value?.layout
    )

    return (option || LAYOUT_OPTIONS[0]).label
  },

  set(label) {
    const option = LAYOUT_OPTIONS.find((item) => item.label === label)

    if (!option || !taskPreferences.value) return

    if (option.value === LAYOUT_CUSTOM && !taskPreferences.value.customRows) {
      taskPreferences.value.customRows = cloneRows(rows.value)
    }

    taskPreferences.value.layout = option.value

    persist()
  }
})

watch(
  () => taskPreferences.value?.layout,
  () => {
    rows.value = arrangementForLayout(taskPreferences.value)
  }
)

function updateColumn(rowIndex, columnIndex, value) {
  rows.value = rows.value.map((row, i) =>
    i === rowIndex
      ? {
          columns: row.columns.map((column, j) =>
            j === columnIndex ? [...value] : column
          )
        }
      : row
  )
}

function syncRows() {
  if (!taskPreferences.value) return

  taskPreferences.value.customRows = cloneRows(rows.value)
  taskPreferences.value.layout = LAYOUT_CUSTOM

  persist()
}

function toggleSplit(index) {
  rows.value = rows.value.map((row, i) => {
    if (i !== index) return row

    return {
      columns:
        row.columns.length > 1 ? [row.columns.flat()] : [...row.columns, []]
    }
  })

  syncRows()
}

function addRow() {
  rows.value = [...cloneRows(rows.value), { columns: [[]] }]

  syncRows()
}

function removeRow(index) {
  const next = cloneRows(rows.value)
  const [removed] = next.splice(index, 1)
  const orphans = removed.columns.flat()

  if (orphans.length) {
    const target = next[Math.max(0, index - 1)]

    target.columns[0] = [...target.columns[0], ...orphans]
  }

  rows.value = next

  syncRows()
}

function toggleHideEmptyPanels(event) {
  if (!taskPreferences.value) return

  taskPreferences.value.hideEmptyPanels = event.target.checked

  persist()
}

function toggleSection(key) {
  if (!taskPreferences.value) return

  taskPreferences.value.sections = sections.value.includes(key)
    ? sections.value.filter((k) => k !== key)
    : flattenRows(rows.value).filter(
        (k) => sections.value.includes(k) || k === key
      )

  persist()
}

function reset() {
  if (!taskPreferences.value) return

  const defaults = structuredClone(DEFAULT_PREFERENCES)

  Object.assign(taskPreferences.value, {
    sections: defaults.sections,
    layout: defaults.layout,
    customRows: defaults.customRows
  })

  rows.value = arrangementForLayout(taskPreferences.value)

  persist()
}

function persist() {
  setPreference(props.storageKey, copyObject(taskPreferences.value))
}
</script>

<style lang="scss" scoped>
.layout-columns {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
}

.layout-columns--split {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.layout-column {
  min-height: 48px;
  padding: var(--spacing-xs);
  border-radius: var(--border-radius-small);
  border: 1px solid var(--border-color);
}

.layout-column--empty {
  border-style: dashed;
  border-color: var(--border-color);
  background-color: transparent;
}
</style>
