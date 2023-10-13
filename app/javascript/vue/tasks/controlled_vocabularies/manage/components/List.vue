<template>
  <div class="three_quarter_width margin-medium-left">
    <spinner-component v-if="isLoading" />
    <table class="full_width">
      <thead>
        <tr>
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
import { ref } from 'vue'
import { sortArray } from '@/helpers'
import SpinnerComponent from '@/components/spinner.vue'
import PinComponent from '@/components/ui/Pinboard/VPin.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['edit', 'sort', 'remove'])

const isLoading = ref(false)
const ascending = ref(false)

function editItem(index) {
  emit('edit', props.list[index])
}

function sortTable(sortProperty) {
  emit('sort', sortArray(props.list, sortProperty, ascending.value))
  ascending.value = !ascending.value
}
</script>
