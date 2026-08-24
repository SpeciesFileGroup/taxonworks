<template>
  <table class="table-striped">
    <thead>
      <tr>
        <td>
          <VBtn
            color="primary"
            medium
            @click="emit('refresh')"
          >
            Refresh
          </VBtn>
        </td>
        <th />
        <th
          v-if="attributes.length"
          :colspan="attributes.length"
          scope="colgroup"
        >
          Attributes
        </th>

        <th
          v-if="predicates.length"
          :colspan="predicates.length"
          scope="colgroup"
          class="cell-left-border"
        >
          Data attributes
        </th>
        <th
          v-if="previewHeader.length"
          class="cell-left-border"
          :colspan="previewHeader.length + 1"
        >
          <div class="flex-separate middle">
            <span>Preview</span>
            <VBtn
              color="primary"
              medium
              :disabled="!totalChanges"
              @click="emit('sort:preview')"
            >
              Gather
            </VBtn>
          </div>
        </th>
      </tr>
      <tr>
        <th>ID</th>
        <th class="label-column">Label</th>
        <th
          v-for="attr in attributes"
          :key="attr"
        >
          <div class="flex-separate middle gap-small">
            <VIcon
              v-if="noEditable.includes(attr)"
              name="attention"
              color="attention"
              small
              title="This attribute is not editable"
            />
            <a
              :href="`${RouteNames.ProjectVocabulary}?limit=100&model=${model}&attribute=${attr}`"
              >{{ attr }}</a
            >
            <div class="horizontal-left-content middle gap-small">
              <VBtn
                color="primary"
                medium
                @click="emit('sort:property', attr)"
              >
                Gather empty
              </VBtn>
              <VBtn
                v-if="!noEditable.includes(attr)"
                color="primary"
                circle
                @click="updateAttributeColumn({ title: attr })"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <VBtn
                color="primary"
                circle
                @click="emit('remove:attribute', attr)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </div>
        </th>
        <th
          v-for="(predicate, index) in predicates"
          :key="predicate.id"
          :class="{ 'cell-left-border': !index }"
        >
          <div class="flex-separate middle gap-medium">
            <span>{{ predicate.name }}</span>
            <div class="horizontal-left-content middle gap-small">
              <VBtn
                color="primary"
                medium
                @click="emit('sort:property', predicate)"
              >
                Gather empty
              </VBtn>
              <VBtn
                color="primary"
                circle
                @click="
                  updatePredicateColumn({
                    title: predicate.name,
                    predicateId: predicate.id
                  })
                "
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <VBtn
                color="primary"
                circle
                @click="emit('remove:predicate', predicate)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </div>
        </th>
        <template v-if="previewHeader.length">
          <th
            v-for="(header, index) in previewHeader"
            :key="index"
            :class="index == 0 && 'cell-left-border'"
          >
            <div class="flex-separate middle gap-small">
              <span>{{ header }}</span>
              <VBtn
                v-if="!isExtract"
                color="update"
                medium
                :disabled="!totalChanges"
                @click="updateAll"
              >
                Apply all ({{ totalChanges }})
              </VBtn>
            </div>
          </th>
          <th v-if="isExtract">
            <VBtn
              color="update"
              medium
              :disabled="!totalChanges"
              @click="updateAll"
            >
              Apply all
            </VBtn>
          </th>
        </template>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(item, rowIndex) in list"
        :key="item.uuid"
      >
        <td>{{ item.id }}</td>
        <td
          class="label-column ellipsis"
          :title="item.label"
          v-html="item.labelHtml"
        />
        <VTableCellAttribute
          v-for="key in attributes"
          :key="key"
          :attribute="key"
          :item="item"
          :row-index="rowIndex"
          :save-attribute-function="saveAttributeFunction"
          :disabled="noEditable.includes(key)"
          @paste="pasteColumns"
        />
        <VTableCellDataAttribute
          v-for="(predicate, index) in predicates"
          :key="predicate.id"
          :class="{ 'cell-left-border': !index }"
          :item="item"
          :predicate="predicate"
          :row-index="rowIndex"
          :save-data-attribute-function="saveDataAttributeFunction"
          @paste="pasteColumns"
        >
        </VTableCellDataAttribute>
        <template v-if="previewHeader.length">
          <td
            v-if="isExtract"
            class="cell-left-border"
          >
            <div
              v-for="{ from } in item.preview"
              :key="from.id"
              class="horizontal-left-content gap-small"
            >
              <input
                type="text"
                disabled
                :class="[
                  'preview-input',
                  from.hasChanged && 'preview-input-changed'
                ]"
                :value="from.value"
              />
            </div>
          </td>
          <td :class="!isExtract && 'cell-left-border'">
            <div
              v-for="({ to }, index) in item.preview"
              :key="to.id"
              class="horizontal-left-content gap-small"
            >
              <input
                type="text"
                disabled
                :class="[
                  'preview-input',
                  to.hasChanged && 'preview-input-changed'
                ]"
                :value="to.value"
              />
              <VBtn
                v-if="!isExtract"
                color="update"
                medium
                :disabled="!to.hasChanged"
                @click="
                  () => {
                    emit('update:preview', {
                      toItems: [
                        {
                          index,
                          item,
                          value: to.value
                        }
                      ]
                    })
                  }
                "
              >
                Apply
              </VBtn>
            </div>
          </td>
          <td v-if="isExtract">
            <div class="flex-col gap-small">
              <VBtn
                v-for="({ to, from }, index) in item.preview"
                :key="from.id"
                color="update"
                medium
                :disabled="!to.hasChanged || !from.hasChanged"
                @click="
                  () => {
                    emit('update:preview', {
                      fromItems: [
                        {
                          index,
                          item,
                          value: from.value
                        }
                      ],
                      toItems: [
                        {
                          index,
                          item,
                          value: to.value
                        }
                      ]
                    })
                  }
                "
              >
                Apply both
              </VBtn>
            </div>
          </td>
        </template>
      </tr>
    </tbody>
  </table>
  <EditColumn ref="editColumnRef" />
  <PasteColumns
    ref="pasteColumnsRef"
    :max-records-without-confirmation="MAX_RECORDS_WITHOUT_CONFIRMATION"
  />
  <ConfirmationModal ref="confirmationRef" />
</template>

<script setup>
import { computed, ref } from 'vue'
import { isEmpty, parseClipboardTable } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import EditColumn from './EditColumn.vue'
import PasteColumns from './PasteColumns.vue'
import VTableCellAttribute from './VTableCellAttribute.vue'
import VTableCellDataAttribute from './VTableCellDataAttribute.vue'

const MAX_RECORDS_WITHOUT_CONFIRMATION = 10

const props = defineProps({
  noEditable: {
    type: Array,
    default: () => []
  },

  saveAttributeFunction: {
    type: Function,
    required: true
  },

  saveDataAttributeFunction: {
    type: Function,
    required: true
  },

  attributes: {
    type: Array,
    default: () => []
  },

  list: {
    type: Array,
    default: () => []
  },

  isExtract: {
    type: Boolean,
    required: true
  },

  predicates: {
    type: Object,
    default: undefined
  },

  previewHeader: {
    type: Array,
    default: () => []
  },

  model: {
    type: String,
    required: true
  }
})

const emit = defineEmits([
  'remove:attribute',
  'remove:predicate',
  'update:attribute',
  'update:attribute-column',
  'update:predicate-column',
  'update:data-attribute',
  'update:preview',
  'paste:columns',
  'refresh',
  'sort:preview',
  'sort:property'
])

const confirmationRef = ref(null)
const editColumnRef = ref(null)
const pasteColumnsRef = ref(null)

const tableColumns = computed(() => [
  ...props.attributes.map((attr) => ({
    kind: 'attribute',
    key: attr,
    label: attr,
    isEditable: !props.noEditable.includes(attr)
  })),
  ...props.predicates.map((predicate) => ({
    kind: 'predicate',
    key: predicate.id,
    label: predicate.name,
    isEditable: true
  }))
])

async function pasteColumns({ text, rowIndex, columnKey, kind }) {
  const rows = parseClipboardTable(text)
  const columnIndex = tableColumns.value.findIndex(
    (column) => column.kind === kind && column.key === columnKey
  )

  if (!rows.length || columnIndex < 0) {
    return
  }

  const availableRows = props.list.length - rowIndex
  const candidates = []
  const skipped = {
    rows: Math.max(rows.length - availableRows, 0),
    columns: 0,
    noEditable: 0,
    ambiguous: 0
  }

  rows.slice(0, availableRows).forEach((cells, index) => {
    const item = props.list[rowIndex + index]

    cells.forEach((cell, cellIndex) => {
      const column = tableColumns.value[columnIndex + cellIndex]
      const value = cell.trim()

      if (!column) {
        skipped.columns++
        return
      }

      if (column.kind === 'attribute') {
        if (!column.isEditable) {
          skipped.noEditable++
          return
        }

        candidates.push({
          column,
          item,
          value,
          currentValue: item.attributes[column.key]
        })
      } else {
        const dataAttributes = item.dataAttributes[column.key]

        if (dataAttributes?.length !== 1) {
          skipped.ambiguous++
          return
        }

        const [dataAttribute] = dataAttributes

        candidates.push({
          column,
          item,
          value,
          dataAttribute,
          currentValue: dataAttribute.value
        })
      }
    })
  })

  const changed = candidates.filter(
    (candidate) => candidate.value !== String(candidate.currentValue ?? '')
  )
  const onlyEmpty = changed.filter((candidate) =>
    isEmpty(candidate.currentValue)
  )
  const columnLabels = [
    ...new Set(candidates.map((candidate) => candidate.column.label))
  ]

  try {
    const payload = await pasteColumnsRef.value.show({
      rowCount: Math.min(rows.length, availableRows),
      columnLabels,
      totalReplace: changed.length,
      totalFillEmpty: onlyEmpty.length,
      skipped
    })

    if (payload) {
      const attributeRecords = []
      const dataAttributeRecords = []

      ;(payload.replace ? changed : onlyEmpty).forEach(
        ({ column, item, value, dataAttribute }) => {
          if (column.kind === 'attribute') {
            attributeRecords.push({ item, attribute: column.key, value })
          } else {
            dataAttributeRecords.push({
              ...dataAttribute,
              objectId: item.id,
              value
            })
          }
        }
      )

      emit('paste:columns', { attributeRecords, dataAttributeRecords })
    }
  } catch {
    /* empty */
  }
}

const totalChanges = computed(
  () =>
    props.list.filter((item) => item.preview.some((item) => item.to.hasChanged))
      .length
)

async function updateAll() {
  const toItems = []
  const fromItems = []

  props.list.forEach((item) => {
    item.preview.forEach((p, index) => {
      if (p.to.hasChanged) {
        toItems.push({
          index,
          item,
          value: p.to.value
        })
      }

      if (p.from?.hasChanged) {
        fromItems.push({
          index,
          item,
          value: p.from.value
        })
      }
    })
  })

  const total = fromItems.length + toItems.length

  const opts = {
    title: 'Mass update',
    message: `This operation will update ${total} record(s). Are you sure you want to proceed?`,
    confirmationWord: 'UPDATE',
    typeButton: 'submit'
  }

  const ok =
    total <= MAX_RECORDS_WITHOUT_CONFIRMATION ||
    (await confirmationRef.value.show(opts))

  if (ok) {
    emit('update:preview', { toItems, fromItems })
  }
}

async function updateAttributeColumn({ title }) {
  try {
    const payload = await editColumnRef.value.show({ title })

    if (payload) {
      const items = payload.replace
        ? props.list
        : props.list.filter((item) => isEmpty(item.attributes[title]))

      const records = items.map((item) => ({
        item,
        attribute: title,
        value: payload.value
      }))

      emit('update:attribute-column', records)
    }
  } catch {
    /* empty */
  }
}

async function updatePredicateColumn({ predicateId, title }) {
  try {
    const payload = await editColumnRef.value.show({ title })

    if (payload) {
      const items = props.list
        .map((item) => {
          return item.dataAttributes[predicateId].map((da) => ({
            ...da,
            objectId: item.id,
            value: payload.value
          }))
        })
        .flat()

      const records = payload.replace ? items : items.filter((item) => !item.id)

      emit('update:predicate-column', records)
    }
  } catch {
    /* empty */
  }
}
</script>

<style scoped>
.cell-left-border {
  border-left: 3px var(--border-color) solid;
}

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;
  outline-offset: -2px;
}

.label-column {
  width: 16rem;
  max-width: 16rem;
}

input {
  width: 320px;
}

.preview-input {
  opacity: 0.25;
  min-width: 320px;
  width: 100%;
}

.preview-input-changed {
  opacity: 1;
}
</style>
