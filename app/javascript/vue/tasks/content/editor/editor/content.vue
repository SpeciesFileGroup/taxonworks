<template>
  <div
    class="panel content"
    id="panel-editor">
    <div class="flexbox">
      <div class="left">
        <div class="flex-separate">
          <div class="title">
            <span>
              <span v-if="topic">{{ topic.name }}</span> -
              <span
                v-if="otu"
                v-html="otu.object_tag"/>
            </span>
          </div>
          <div class="horizontal-left-content middle">
            <radial-annotator
              v-if="content"
              type="annotations"
              :global-id="content.global_id"/>
            <otu-button
              v-if="otu"
              :otu="otu"
              class="separate-options"
              redirect
            />
            <radial-object
              v-if="otu"
              :global-id="otu.global_id"/>
            <select-topic-otu
              class="separate-left"
              @close="$refs.contentText.setFocus()"/>
          </div>
        </div>
        <div
          v-if="disabled"
          class="CodeMirror cm-s-paper CodeMirror-wrap"/>
        <template v-else>
          <markdown-editor
            v-if="loadMarkwdown"
            class="edit-content"
            v-model="record.content.text"
            :configs="config"
            @input="handleInput"
            ref="contentText"
          />
        </template>
      </div>
      <div
        v-if="compareContent && !preview"
        class="right">
        <div class="title">
          <span>
            <span v-html="compareContent.topic.object_tag"/> -
            <span v-html="compareContent.otu.object_tag"/>
          </span>
        </div>
        <div class="compare-toolbar middle">
          <button
            class="button normal-input button-default"
            @click="compareContent = undefined">Close compare
          </button>
        </div>
        <div
          class="compare"
          @mouseup="copyCompareContent">
          {{ compareContent.text }}
        </div>
      </div>
    </div>
    <div class="flex-separate menu-content-editor">
      <div
        class="item flex-wrap-column middle menu-item menu-button"
        @click="update"
        :class="{ saving : autosave }">
        <span
          data-icon="savedb"
          class="big-icon"/>
        <span class="tiny_space">Save</span>
      </div>
      <clone-content
        @addCloneCitation="addText"
        class="item menu-item"/>
      <compare-content
        class="item menu-item"
        @showCompareContent="showCompare"/>
      <div
        class="item flex-wrap-column middle menu-item menu-button"
        @click="ChangeStateFigures()"
        :class="{ active : activeFigures, disabled : !content }">
        <span
          data-icon="new"
          class="big-icon"/>
        <span class="tiny_space">Figure</span>
      </div>
    </div>
  </div>
</template>

<script>
import CloneContent from './clone.vue'
import CompareContent from './compare.vue'
import SelectTopicOtu from './selectTopicOtu.vue'
import MarkdownEditor from 'components/markdown-editor.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import OtuButton from 'components/otu/otu'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Content } from 'routes/endpoints'

const extend = ['otu', 'topic']

export default {
  components: {
    CloneContent,
    CompareContent,
    MarkdownEditor,
    SelectTopicOtu,
    RadialAnnotator,
    RadialObject,
    OtuButton
  },

  data () {
    return {
      autosave: 0,
      firstInput: true,
      loadMarkwdown: true,
      currentSourceID: '',
      newRecord: true,
      preview: false,
      compareContent: undefined,
      record: {
        content: this.initContent()
      },
      config: {
        status: false,
        spellChecker: false
      }

    }
  },

  computed: {
    topic () {
      return this.$store.getters[GetterNames.GetTopicSelected]
    },

    otu () {
      return this.$store.getters[GetterNames.GetOtuSelected]
    },

    content () {
      return this.$store.getters[GetterNames.GetContentSelected]
    },

    disabled () {
      return !this.topic || !this.otu
    },

    activeFigures () {
      return this.$store.getters[GetterNames.PanelFigures]
    }
  },

  watch: {
    otu (newVal, oldVal) {
      if (
        newVal?.id &&
        newVal.id !== oldVal?.id &&
        this.topic?.id
      ) {
        this.loadContent()
      }
    },

    topic (newVal, oldVal) {
      if (
        newVal?.id &&
        newVal.id !== oldVal?.id &&
        this.otu?.id
      ) {
        this.loadContent()
      }
    }
  },

  methods: {
    initContent () {
      return {
        id: undefined,
        otu_id: undefined,
        topic_id: undefined,
        text: ''
      }
    },

    addText (text) {
      this.record.content.text += text
      this.autoSave()
    },

    showCompare (content) {
      this.compareContent = content
      this.preview = false
    },

    ChangeStateFigures () {
      this.$store.commit(MutationNames.ChangeStateFigures)
    },

    copyCompareContent () {
      if (window.getSelection) {
        if (window.getSelection().toString().length > 0) {
          this.record.content.text += window.getSelection().toString()
          this.autoSave()
        }
      }
    },

    handleInput () {
      if (this.firstInput) {
        this.firstInput = false
      } else {
        this.autoSave()
      }
    },

    resetAutoSave () {
      clearTimeout(this.autosave)
      this.autosave = null
    },

    autoSave () {
      if (this.autosave) {
        this.resetAutoSave()
      }
      this.autosave = setTimeout(() => {
        this.update()
      }, 3000)
    },

    update () {
      this.resetAutoSave()

      if (this.disabled || (this.record.content.text === '')) return

      if (this.record.content.id) {
        Content.update(this.record.content.id, { ...this.record, extend })
      } else {
        Content.create({ ...this.record, extend }).then(response => {
          this.record.content.id = response.body.id
          this.$store.commit(MutationNames.SetContentSelected, response.body)
        })
      }
    },

    loadContent () {
      if (this.disabled) return

      const params = {
        otu_id: this.otu.id,
        topic_id: this.topic.id,
        extend
      }

      this.firstInput = true
      this.resetAutoSave()

      Content.where(params).then(response => {
        if (response.body.length > 0) {
          const record = response.body[0]

          this.record.content = {
            id: record.id,
            text: record.text,
            topic_id: record.topic_id,
            otu_id: record.otu_id
          }

          this.newRecord = false
          this.$store.commit(MutationNames.SetContentSelected, response.body[0])
          this.$refs.contentText.setFocus()
        } else {
          const content = {
            ...this.initContent(),
            topic_id: this.topic.id,
            otu_id: this.otu.id
          }

          this.record.content = content
          this.$store.commit(MutationNames.SetContent, undefined)
          this.newRecord = true
          this.$refs.contentText.setFocus()
        }
      })
      this.loadMarkwdown = false
      this.$nextTick(() => {
        this.loadMarkwdown = true
      })
    }
  }
}
</script>
