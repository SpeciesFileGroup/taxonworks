<template>
  <ul class="annotations__tag_list">
    <li
      v-for="tag in tags"
      :key="tag.id"
    >
      <span
        class="annotation__tag"
        v-html="tag.keyword.object_tag"
      />
    </li>
  </ul>
</template>

<script setup>
import { SOURCE } from '@/constants'
import { Tag } from '@/routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  sourceId: {
    type: [String, Number],
    required: true
  }
})

const tags = ref([])

Tag.where({
  tag_object_id: props.sourceId,
  tag_object_type: SOURCE
}).then((response) => {
  tags.value = response.body
})
</script>
