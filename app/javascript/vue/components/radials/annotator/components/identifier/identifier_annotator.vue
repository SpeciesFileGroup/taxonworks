<template>
  <div class="identifier_annotator">
    <IdentifierList
      :list="typeList"
      v-model="listSelected"
    />
    <div v-if="listSelected">
      <IdentifierType
        v-model="typeIdentifier"
        :list="listSelected"
        :types="typeList[listSelected]"
      />

      <IdentifierLocal
        v-if="isLocal"
        :type="typeIdentifier"
        :object-type="objectType"
        @create="saveIdentifier"
      />
      <IdentifierForm
        v-else
        :type="typeIdentifier"
        @create="saveIdentifier"
      />
    </div>
    <IdentifierTable
      v-model="list"
      @delete="removeItem"
    />
  </div>
</template>
<script setup>
import IdentifierList from './identifierList.vue'
import IdentifierType from './IdentifierType.vue'
import IdentifierLocal from './IdentifierLocal.vue'
import IdentifierForm from './IdentifierForm.vue'
import IdentifierTable from './IdentifierTable.vue'
import { useSlice } from '@/components/radials/composables'
import { Identifier } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import { IDENTIFIER_UNKNOWN } from '@/constants'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const isLocal = computed(() => listSelected.value === 'local')
const typeList = ref([])
const listSelected = ref()
const typeIdentifier = ref(null)
const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

Identifier.types().then(({ body }) => {
  const list = body
  const keys = Object.keys(body)

  keys.forEach((key) => {
    const itemList = list[key]
    itemList.common = Object.fromEntries(
      itemList.common.map((item) => [
        item,
        Object.entries(itemList.all).find(([key]) => key === item)[1]
      ])
    )
  })

  typeList.value = body
})

watch(listSelected, (newVal) => {
  typeIdentifier.value = newVal === 'unknown' ? IDENTIFIER_UNKNOWN : null
})

function saveIdentifier(params) {
  const identifier = {
    ...params,
    type: typeIdentifier.value,
    identifier_object_id: props.objectId,
    identifier_object_type: props.objectType
  }

  Identifier.create({ identifier })
    .then(({ body }) => {
      addToList(body)
      listSelected.value = undefined
    })
    .catch(() => {})
}

function removeItem(item) {
  Identifier.destroy(item.id).then(() => {
    removeFromList(item)
  })
}

Identifier.where({
  identifier_object_id: props.objectId,
  identifier_object_type: props.objectType,
  per: 500
}).then(({ body }) => {
  list.value = body
})
</script>
