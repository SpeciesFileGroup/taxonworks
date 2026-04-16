<template>
  <div
    :class="{ disabled: !store.content.id }"
    :container-style="{ width: '500px' }"
  >
    <div
      class="item flex-wrap-column middle menu-button"
      @click="isModalVisible = true"
    >
      <span
        :data-icon="label"
        class="big-icon"
      />
      <span class="tiny_space capitalize">{{ label }}</span>
    </div>
    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3 class="capitalize">{{ label }}</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="item in contents"
            :key="item.id"
            v-html="item.object_tag"
            @click="selectContent(item)"
          />
        </ul>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Content } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import useContentStore from '../store/store.js'

const emit = defineEmits(['select'])

defineProps({
  label: {
    type: String,
    required: true
  }
})

const store = useContentStore()
const contents = ref([])
const isModalVisible = ref(false)

function loadContent() {
  Content.where({ topic_id: store.topic.id, extend: ['otu', 'topic'] }).then(
    ({ body }) => {
      contents.value = store.content?.id
        ? body.filter((c) => c.id !== store.content.id)
        : body
    }
  )
}

function selectContent(content) {
  emit('select', content)
  isModalVisible.value = false
}

watch(isModalVisible, (newVal) => {
  if (newVal) {
    if (store.otu && store.topic) {
      loadContent()
    }
  } else {
    contents.value = []
  }
})
</script>
