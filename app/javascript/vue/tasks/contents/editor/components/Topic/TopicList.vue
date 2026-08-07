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
    >
      <template
        v-if="addAll"
        #all-top
      >
        <VBtn
          color="primary"
          medium
          :disabled="!topics.length"
          @click="selectedAll"
        >
          Add all
        </VBtn>
      </template>
      <template
        v-if="addAll"
        #all
      >
        <VBtn
          color="primary"
          medium
          :disabled="!topics.length"
          @click="selectedAll"
        >
          Add all
        </VBtn>
      </template>
    </smart-selector>
    <topic-new
      class="margin-medium-top"
      @create="selected"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import TopicNew from './TopicNew.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { Topic } from '@/routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  addAll: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['select', 'select-all'])

const topics = ref([])

function selected(topic) {
  emit('select', topic)
}

function selectedAll() {
  emit('select-all', topics.value)
}

Topic.all().then(({ body }) => {
  topics.value = body
})
</script>
