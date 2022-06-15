<template>
  <div class="panel content">
    <h3>{{ name }}</h3>
    <div class="horizontal-left-content">
      <ul class="no_bullets context-menu">
        <li>Published: {{ published }}</li>
        <li>Unpublished: {{ unpublished }}</li>
        <li>
          <PublishAll
            class="margin-small-right"
            :topic-id="topicId"
          />
          <UnpublishAll
            class="margin-small-right"
            :topic-id="topicId"
          />
          <VBtn
            color="primary"
            medium
            @click="isContentListVisible = true"
          >
            Expand
          </VBtn>
        </li>
      </ul>
    </div>
    <ContentList
      v-if="isContentListVisible"
      :topic-id="topicId"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'
import PublishAll from './PublishAll.vue'
import UnpublishAll from './UnpublishAll.vue'
import ContentList from '../Content/ContentList.vue'

defineProps({
  topicId: {
    type: Number,
    required: true
  },

  name: {
    type: String,
    required: true
  },

  published: {
    type: Number,
    default: 0
  },

  unpublished: {
    type: Number,
    default: 0
  }
})

const isContentListVisible = ref(false)

</script>
