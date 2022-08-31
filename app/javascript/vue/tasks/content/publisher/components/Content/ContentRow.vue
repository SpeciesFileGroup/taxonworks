<template>
  <tr class="contextMenuCells">
    <td>{{ content.text }}</td>
    <td />
    <td v-html="content.otu" />
    <td>
      <VToggle
        v-model="publishedValue"
        :value="content.published"
      />
    </td>
  </tr>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../../composables/useStore.js'
import VToggle from 'components/ui/VToggle.vue'

const props = defineProps({
  content: {
    type: Object,
    required: true
  },

  topicId: {
    type: Number,
    required: true
  }
})

const store = useStore()
const publishedValue = computed({
  get: () => props.content.published,

  set: value => {
    store.updateContent({
      contentId: props.content.id,
      topicId: props.topicId,
      isPublic: value
    })
  }
})

</script>
