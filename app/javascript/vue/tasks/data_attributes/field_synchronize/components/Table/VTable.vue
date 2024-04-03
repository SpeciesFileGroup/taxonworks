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
        </th>
        <th
          v-for="(predicate, index) in predicates"
          :key="predicate.id"
          :class="{ 'cell-left-border': !index }"
        >
          {{ predicate.name }}
        </th>
        <th
          class="cell-left-border"
          v-if="previewHeader"
        >
          {{ previewHeader }}
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
          <input
            v-for="(p, index) in item.preview"
            type="text"
            disabled
            :value="p"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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
  'update:attribute',
  'update:data-attribute'
])
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
