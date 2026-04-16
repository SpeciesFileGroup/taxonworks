<template>
  <div>
    <smart-selector
      :autocomplete-params="{ 'type[]': 'Topic' }"
      model="topics"
      target="Content"
      klass="Content"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      get-url="/controlled_vocabulary_terms/"
      :custom-list="{ all: topics }"
      @selected="selected"
    />
    <topic-new
      class="margin-medium-top"
      @create="selected"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import TopicNew from './TopicNew.vue'
import { Topic } from '@/routes/endpoints'
import { ref } from 'vue'

const emit = defineEmits(['select'])

const topics = ref([])

function selected(topic) {
  emit('select', topic)
}

Topic.all().then(({ body }) => {
  topics.value = body
})
</script>
