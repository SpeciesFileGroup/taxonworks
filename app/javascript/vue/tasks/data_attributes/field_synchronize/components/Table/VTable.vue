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
              :disabled="!hasChanges"
              @click="emit('sort:preview')"
            >
              Gather
            </VBtn>
          </div>
        </th>
      </tr>
      <tr>
        <th>ID</th>
        <th
          v-for="attr in attributes"
          :key="attr"
        >
          <div class="flex-separate middle gap-medium">
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
                :disabled="!hasChanges"
                @click="updateAll"
              >
                Apply all ({{ hasChanges }})
              </VBtn>
            </div>
          </th>
          <th v-if="isExtract">
            <VBtn
              color="update"
              medium
              :disabled="!hasChanges"
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
        v-for="item in list"
        :key="item.uuid"
        class="contextMenuCells"
      >
        <td>{{ item.id }}</td>
        <td
          v-for="key in attributes"
          :key="key"
        >
          <input
            type="text"
            :value="item.attributes[key]"
            class="full_width"
            :disabled="noEditable.includes(key)"
            @change="
              (e) =>
                emit('update:attribute', {
                  item: item,
                  attribute: key,
                  value: e.target.value
                })
            "
          />
        </td>
        <td
          v-for="(predicate, index) in predicates"
          :key="predicate.id"
          :class="{ 'cell-left-border': !index }"
        >
          <input
            v-for="dataAttribute in item.dataAttributes[predicate.id]"
            :key="dataAttribute.uuid"
            class="full_width d-block"
            type="text"
            :value="dataAttribute.value"
            @change="
              (e) => {
                emit('update:data-attribute', {
                  id: dataAttribute.id,
                  objectId: item.id,
                  predicateId: dataAttribute.predicateId,
                  uuid: dataAttribute.uuid,
                  value: e.target.value
                })
              }
            "
          />
        </td>
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
  <ConfirmationModal ref="confirmationRef" />
</template>

<script setup>
import { computed, ref } from 'vue'
import { isEmpty } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import EditColumn from './EditColumn.vue'

const MAX_RECORDS_WITHOUT_CONFIRMATION = 10

const props = defineProps({
  noEditable: {
    type: Array,
    default: () => []
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
  'refresh',
  'sort:preview',
  'sort:property'
])

const confirmationRef = ref(null)
const editColumnRef = ref(null)

const hasChanges = computed(
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
  border-left: 3px #eaeaea solid;
}

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;
  outline-offset: -2px;
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
