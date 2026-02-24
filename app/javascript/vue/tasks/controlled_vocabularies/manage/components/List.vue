<template>
  <div class="three_quarter_width margin-medium-left">
    <spinner-component v-if="isLoading" />
    <table class="full_width">
      <thead>
        <tr>
          <th class="w-2">
            <ButtonUnify
              :model="CONTROLLED_VOCABULARY_TERM"
              :ids="unifyIds"
            />
          </th>
          <th @click="sortTable('name')">Name</th>
          <th @click="sortTable('definition')">Definition</th>
          <th @click="sortTable('count')">Uses</th>
          <th>Show</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in list"
          :key="item.id"
        >
          <td>
            <input
              type="checkbox"
              :value="item.id"
              v-model="unifyIds"
            />
          </td>
          <td
            class="line-nowrap"
            v-html="item.object_tag"
          />
          <td>{{ item.definition }}</td>
          <td>{{ item.count }}</td>
          <td>
            <a :href="`/controlled_vocabulary_terms/${item.id}`">Show</a>
          </td>
          <td>
            <div class="horizontal-right-content gap-small">
              <VBtn
                color="primary"
                circle
                @click="editItem(index)"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <PinComponent
                class="button button-circle"
                v-if="item.id"
                :object-id="item.id"
                :section="`${item.type}s`"
                type="ControlledVocabularyTerm"
              />
              <VBtn
                color="destroy"
                circle
                @click="emit('remove', item)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    <span>{{ list.length }} records.</span>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { sortArray } from '@/helpers'
import { CONTROLLED_VOCABULARY_TERM } from '@/constants'
import SpinnerComponent from '@/components/ui/VSpinner.vue'
import PinComponent from '@/components/ui/Button/ButtonPin.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['edit', 'sort', 'remove'])

const isLoading = ref(false)
const ascending = ref(false)
const unifyIds = ref([])

function editItem(index) {
  emit('edit', props.list[index])
}

function sortTable(sortProperty) {
  emit('sort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}

watch(unifyIds, (ids) => {
  if (ids.length > 2) {
    ids.shift()
  }
})

watch(
  () => props.list,
  (newVal) => {
    unifyIds.value = unifyIds.value.filter((id) =>
      newVal.some((c) => c.id === id)
    )
  }
)
</script>
