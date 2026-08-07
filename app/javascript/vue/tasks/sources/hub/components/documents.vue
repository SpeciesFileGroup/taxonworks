<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="item in documentation"
        :key="item.id"
      >
        <a
          class="btn-download circle-button"
          :href="item.document.file_url"
          download
        />
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Documentation } from '@/routes/endpoints'
import { SOURCE } from '@/constants'

const props = defineProps({
  sourceId: {
    type: [String, Number],
    required: true
  }
})

const documentation = ref([])

Documentation.where({
  documentation_object_id: props.sourceId,
  documentation_object_type: SOURCE
}).then(({ body }) => {
  documentation.value = body
})
</script>
