<template>
  <table class="table-striped">
    <thead>
      <tr>
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
          v-if="previewHeader"
          class="cell-left-border"
        >
          Preview
        </th>
      </tr>
      <tr>
        <th
          v-for="attr in attributes"
          :key="attr"
        >
          <div class="flex-separate middle gap-medium">
            {{ attr }}
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
        </th>
        <th
          v-for="(predicate, index) in predicates"
          :key="predicate.id"
          :class="{ 'cell-left-border': !index }"
        >
          <div class="flex-separate middle gap-medium">
            <span>{{ predicate.name }}</span>
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
        </th>
        <th
          class="cell-left-border"
          v-if="previewHeader"
        >
          <div class="flex-separate middle gap-medium">
            <span>{{ previewHeader }}</span>
            <VBtn
              color="update"
              medium
              :disabled="!hasChanges"
              @click="updateAll"
            >
              Apply all
            </VBtn>
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
        class="contextMenuCells"
      >
        <td
          v-for="key in attributes"
          :key="key"
        >
          <input
            type="text"
            :value="item.attributes[key]"
            class="full_width"
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
            class="full_width"
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
        <td
          v-if="previewHeader"
          class="cell-left-border"
        >
          <div
            v-for="(obj, index) in item.preview"
            :key="obj.id"
            class="horizontal-left-content gap-small"
          >
            <input
              type="text"
              disabled
              class="full_width"
              :value="obj.value"
            />
            <VBtn
              color="update"
              medium
              :disabled="!obj.hasChanged"
              @click="
                () => {
                  emit('update:preview', [
                    {
                      index,
                      item,
                      value: obj.value
                    }
                  ])
                }
              "
            >
              Apply
            </VBtn>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
  <ConfirmationModal ref="confirmationRef" />
</template>

<script setup>
import { computed, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const props = defineProps({
  attributes: {
    type: Array,
    default: () => []
  },

  list: {
    type: Array,
    default: () => []
  },

  predicates: {
    type: Object,
    default: undefined
  },

  previewHeader: {
    type: String,
    default: ''
  }
})

const emit = defineEmits([
  'remove:attribute',
  'remove:predicate',
  'update:attribute',
  'update:data-attribute',
  'update:preview'
])

const confirmationRef = ref()

const hasChanges = computed(() =>
  props.list.some((item) => item.preview.some((item) => item.hasChanged))
)

async function updateAll() {
  const items = []

  props.list.forEach((item) => {
    item.preview.forEach((p, index) => {
      if (p.hasChanged) {
        items.push({
          index,
          item,
          value: p.value
        })
      }
    })
  })

  const opts = {
    title: 'Mass update',
    message: `This operation will update ${items.length} record(s). Are you sure you want to proceed?`,
    confirmationWord: 'update',
    typeButton: 'submit'
  }

  const ok = await confirmationRef.value.show(opts)

  if (ok) {
    emit('update:preview', items)
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
</style>
