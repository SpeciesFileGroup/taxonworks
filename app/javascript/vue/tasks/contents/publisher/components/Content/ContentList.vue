<template>
  <table>
    <thead>
      <tr>
        <th class="full_width">Text</th>
        <th>Otu</th>
        <th>Unpublish/Publish</th>
      </tr>
    </thead>
    <tbody>
      <ContentRow
        v-for="item in list"
        :key="item.id"
        :content="item"
        :topic-id="topicId"
      />
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../../composables/useStore'
import ContentRow from './ContentRow.vue'

const props = defineProps({
  topicId: {
    type: Number,
    required: true
  }
})

const { requestTopicTable, getContentsByTopicId } = useStore()

const list = computed(() => getContentsByTopicId(props.topicId) || [])

requestTopicTable(props.topicId)
</script>
