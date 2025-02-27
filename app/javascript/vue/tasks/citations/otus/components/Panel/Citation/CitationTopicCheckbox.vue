<template>
  <div>
    <label class="cursor-pointer">
      <input
        type="checkbox"
        :disabled="isDisabled"
        v-model="toggleTopic"
      />
      <span>
        <span v-html="topic.object_tag" />
      </span>
    </label>
  </div>
</template>

<script setup>
import useStore from '../../../store/store.js'
import { computed } from 'vue'

const props = defineProps({
  topic: {
    type: Object,
    required: true
  }
})

const store = useStore()
const isDisabled = computed(() => !store.selected.otu || !store.selected.source)

const toggleTopic = computed({
  get() {
    return store.selected.citationTopics.some(
      (t) => t.topic_id === props.topic.id
    )
  },

  set(value) {
    if (value) {
      store.createTopicCitation({
        citationId: store.selected.citation.id,
        topicId: props.topic.id
      })

      TW.workbench.alert.create('Citation topic was successfully created.')
    } else {
      const topic = store.selected.citationTopics.find(
        (item) => item.topic_id === props.topic.id
      )

      store.destroyTopic(topic).then(() => {
        TW.workbench.alert.create('Citation topic was successfully destroyed.')
      })
    }
  }
})
</script>
