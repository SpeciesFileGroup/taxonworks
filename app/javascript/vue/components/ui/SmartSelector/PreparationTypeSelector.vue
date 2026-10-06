<template>
  <div>
    <SmartSelector
      ref="smartSelectorRef"
      model="preparation_types"
      :target="target"
      :add-tabs="['all']"
      :autofocus="autofocus"
      :klass="target"
      pin-section="PreparationTypes"
      pin-type="PreparationType"
      v-model="preparationType"
      @selected="setPreparationType"
    >
      <template #tabs-right>
        <slot name="tabs-right" />
      </template>
      <template #all>
        <VModal
          :container-style="{ width: '800px', maxWidth: '90vw' }"
          @close="closeAll"
        >
          <template #header>
            <h3>Preparation types</h3>
          </template>
          <template #body>
            <div class="flex-wrap-row gap-medium align-start">
              <ul
                v-for="(group, index) in columns"
                :key="index"
                class="no_bullets all-column"
              >
                <li
                  v-for="item in group"
                  :key="item.id"
                  class="list__item"
                >
                  <label
                    class="cursor-pointer"
                    @click.prevent="selectFromAll(item)"
                  >
                    <input
                      type="radio"
                      :name="radioName"
                      :value="item.id"
                      :checked="preparationType?.id === item.id"
                    />
                    <span
                      :title="item.name"
                      v-html="item.object_tag"
                    />
                  </label>
                </li>
              </ul>
            </div>
          </template>
        </VModal>
      </template>
    </SmartSelector>
    <template v-if="preparationType">
      <hr class="divisor" />
      <SmartSelectorItem
        :item="preparationType"
        @unset="setPreparationType(null)"
      />
    </template>
  </div>
</template>

<script setup>
import { computed, ref, watch, useTemplateRef } from 'vue'
import { PreparationType } from '@/routes/endpoints'
import { chunkArray, sortArray } from '@/helpers'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VModal from '@/components/ui/Modal.vue'

const props = defineProps({
  target: {
    type: String,
    default: 'CollectionObject'
  },

  columnCount: {
    type: Number,
    default: 3
  },

  autofocus: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['select'])

const preparationTypeId = defineModel({
  type: Number,
  default: undefined
})

const radioName = Math.random().toString(36).substring(2, 7)
const smartSelectorRef = useTemplateRef('smartSelectorRef')
const preparationType = ref(undefined)
const allList = ref([])

const columns = computed(() =>
  allList.value.length
    ? chunkArray(
        allList.value,
        Math.ceil(allList.value.length / props.columnCount)
      )
    : []
)

watch(
  preparationTypeId,
  (newVal) => {
    if (preparationType.value?.id === newVal) return

    if (newVal) {
      PreparationType.find(newVal).then(({ body }) => {
        preparationType.value = body
      })
    } else {
      preparationType.value = undefined
    }
  },
  { immediate: true }
)

PreparationType.all().then(({ body }) => {
  allList.value = sortArray(body, 'name')
})

function setPreparationType(item) {
  preparationType.value = item || undefined
  preparationTypeId.value = item?.id
  emit('select', item || null)
}

function selectFromAll(item) {
  setPreparationType(item)
  closeAll()
}

function closeAll() {
  smartSelectorRef.value?.setTab('quick')
}
</script>

<style scoped>
.all-column {
  flex: 1;
  min-width: 0;
}
.list__item {
  padding: 2px 0;
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
}
input:focus + span {
  font-weight: bold;
}
</style>
