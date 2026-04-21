<template>
  <div
    id="content_editor"
    class="margin-medium-top"
  >
    <div
      class="flex-separate"
      id="panels-content"
    >
      <div class="item item2 column-big">
        <ContentEditor />
        <FiguresPanel />
      </div>
    </div>
  </div>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { Content } from '@/routes/endpoints'
import { usePopstateListener } from '@/composables'
import ContentEditor from './editor/ContentEditor.vue'
import FiguresPanel from './editor/figuresPanel.vue'
import useStore from './store/store.js'

const store = useStore()

function loadFromIdParameter() {
  const urlParams = new URLSearchParams(window.location.search)
  const contentId = urlParams.get('content_id')

  if (/^\d+$/.test(contentId)) {
    Content.find(contentId, { extend: ['otu', 'topic'] }).then(({ body }) => {
      store.setContent(body)

      store.otu = body.otu
      store.topic = body.topic
    })
  }
}

onBeforeMount(loadFromIdParameter)
usePopstateListener(loadFromIdParameter)
</script>
