<template>
  <div
    class="panel content"
    id="panel-editor"
  >
    <div class="flexbox">
      <div class="left">
        <div class="flex-separate margin-medium-bottom">
          <span>
            <span v-if="store.topic">{{ store.topic.name }}</span> -
            <span
              v-if="store.otu"
              v-html="store.otu.object_tag"
            />
          </span>
          <div class="horizontal-left-content middle gap-small">
            <template v-if="store.content.id">
              <div class="flex-row gap-small middle">
                <span>Publish content</span>
                <PublishContent :content-id="store.content.id" />
              </div>
              <RadialAnnotator
                type="annotations"
                :global-id="store.content.global_id"
              />
            </template>
            <OtuButton
              v-if="store.otu"
              :otu="store.otu"
              redirect
            />
            <RadialObject
              v-if="store.otu"
              :global-id="store.otu.global_id"
            />
            <SelectTopicOtu @close="contentText.setFocus()" />
          </div>
        </div>
        <div
          v-if="isDisabled"
          class="CodeMirror cm-s-paper CodeMirror-wrap"
        />
        <template v-else>
          <MarkdownEditor
            v-if="loadMarkdown"
            ref="contentText"
            class="edit-content"
            v-model="store.content.text"
            :configs="config"
            @input="handleInput"
          />
        </template>
      </div>
      <div
        v-if="compareContent && !preview"
        class="right"
      >
        <div class="title">
          <span>
            <span v-html="compareContent.topic.object_tag" /> -
            <span v-html="compareContent.otu.object_tag" />
          </span>
        </div>
        <div class="compare-toolbar middle">
          <button
            class="button normal-input button-default"
            @click="compareContent = undefined"
          >
            Close compare
          </button>
        </div>
        <div
          class="compare"
          @mouseup="copyCompareContent"
        >
          {{ compareContent.text }}
        </div>
      </div>
    </div>
    <div class="flex-separate menu-content-editor">
      <div
        class="item flex-wrap-column middle menu-item menu-button"
        @click="update"
        :class="{ saving: autosave }"
      >
        <span
          data-icon="savedb"
          class="big-icon"
        />
        <span class="tiny_space">Save</span>
      </div>
      <SelectContent
        class="item menu-item"
        label="clone"
        @select="(content) => addText(content.text)"
      />
      <SelectContent
        class="item menu-item"
        label="compare"
        @select="showCompare"
      />
      <div
        class="item flex-wrap-column middle menu-item menu-button"
        @click="store.panels.figures = !store.panels.figures"
        :class="{ active: store.panels.figures, disabled: !store.content.id }"
      >
        <span
          data-icon="new"
          class="big-icon"
        />
        <span class="tiny_space">Figure</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, useTemplateRef, watch } from 'vue'
import { Content } from '@/routes/endpoints'
import SelectContent from './SelectContent.vue'
import SelectTopicOtu from './selectTopicOtu.vue'
import MarkdownEditor from '@/components/markdown-editor.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import PublishContent from './PublishContent.vue'
import OtuButton from '@/components/otu/otu'
import useContentStore from '../store/store.js'

const extend = ['otu', 'topic']
const config = {
  status: false,
  spellChecker: false
}

const store = useContentStore()
const contentText = useTemplateRef('contentText')
const autosave = ref(0)
const firstInput = ref(true)
const loadMarkdown = ref(true)
const preview = ref(false)
const compareContent = ref()

const isDisabled = computed(() => !store.topic || !store.otu)

function addText(text) {
  store.content.text += text
  autoSave()
}

function showCompare(content) {
  compareContent.value = content
  preview.value = false
}

function copyCompareContent() {
  if (window.getSelection) {
    if (window.getSelection().toString().length > 0) {
      store.content.text += window.getSelection().toString()
      autoSave()
    }
  }
}

function handleInput() {
  if (firstInput.value) {
    firstInput.value = false
  } else {
    autoSave()
  }
}

function resetAutoSave() {
  clearTimeout(autosave.value)
  autosave.value = null
}

function autoSave() {
  if (autosave.value) {
    resetAutoSave()
  }
  autosave.value = setTimeout(() => {
    update()
  }, 3000)
}

function update() {
  resetAutoSave()

  if (isDisabled.value || store.content.text === '') return

  const payload = {
    content: {
      text: store.content.text,
      otu_id: store.otu.id,
      topic_id: store.topic.id
    },
    extend
  }

  const request = store.content.id
    ? Content.update(store.content.id, payload)
    : Content.create(payload)

  request.then(({ body }) => {
    store.setContent(body)
  })
}

function loadContent() {
  if (isDisabled.value) return

  const params = {
    otu_id: store.otu.id,
    topic_id: store.topic.id,
    extend
  }

  firstInput.value = true
  resetAutoSave()

  Content.where(params).then(({ body }) => {
    const [record] = body

    if (record) {
      store.setContent(record)

      store.otu = record.otu
      store.topic = record.topic

      contentText.value?.setFocus()
    } else {
      store.setContent({ text: '' })
      contentText.value?.setFocus()
    }
  })
}

watch([() => store.otu?.id, () => store.topic?.id], () => {
  if (store.otu && store.topic) {
    loadContent()
  }
})
</script>
