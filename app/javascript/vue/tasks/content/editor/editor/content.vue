<template>
  <div
    class="panel"
    id="panel-editor">
    <div class="flexbox">
      <div class="left">
        <div class="title">
          <span>
            <span v-if="topic">{{ topic.name }}</span> -
            <span
              v-if="otu"
              v-html="otu.object_tag"/>
          </span>
          <div class="horizontal-left-content middle">
            <radial-annotator
              v-if="content"
              type="annotations"
              :global-id="content.global_id"/>
            <otu-button
              v-if="otu"
              :otu="otu"
              class="separate-options"
              :redirect="true"/>
            <radial-object 
              v-if="otu"
              :global-id="otu.global_id"/>
            <select-topic-otu class="separate-left"/>
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
            @dblclick="addCitation"/>
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
            class="button button-close"
            @click="compareContent = undefined">Close compare
          </button>
        </div>
        <div
          class="compare"
          @mouseup="copyCompareContent">{{ compareContent.text }}
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
        :class="{ disabled : !content }"
        class="item menu-item"/>
      <compare-content class="item menu-item"/>
      <div
        class="item flex-wrap-column middle menu-item menu-button"
        @click="ChangeStateCitations()"
        :class="{ active : activeCitations, disabled : citations < 1 }">
        <span
          data-icon="citation"
          class="big-icon"/>
        <span class="tiny_space">Citation</span>
      </div>
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
  import AjaxCall from 'helpers/ajaxCall'

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
    computed: {
      topic() {
        return this.$store.getters[GetterNames.GetTopicSelected]
      },
      otu() {
        return this.$store.getters[GetterNames.GetOtuSelected]
      },
      content() {
        return this.$store.getters[GetterNames.GetContentSelected]
      },
      disabled() {
        return (this.topic == undefined || this.otu == undefined)
      },
      citations() {
        return this.$store.getters[GetterNames.GetCitationsList]
      },
      activeCitations() {
        return this.$store.getters[GetterNames.PanelCitations]
      },
      activeFigures() {
        return this.$store.getters[GetterNames.PanelFigures]
      }
    },
    data() {
      return {
        autosave: 0,
        firstInput: true,
        loadMarkwdown: true,
        currentSourceID: '',
        newRecord: true,
        preview: false,
        compareContent: undefined,
        record: {
          content: {
            otu_id: '',
            topic_id: '',
            text: ''
          }
        },
        config: {
          status: false,
          spellChecker: false
        }

      }
    },
    created: function () {
      this.$on('addCloneCitation', function (itemText) {
        this.record.content.text += itemText
        this.autoSave()
      })
      this.$on('showCompareContent', function (content) {
        this.compareContent = content
        this.preview = false
      })
    },
    watch: {
      otu: function (val, oldVal) {
        if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
          this.loadContent()
        }
      },
      topic: function (val, oldVal) {
        if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
          this.loadContent()
        }
      }
    },
    methods: {
      ChangeStateFigures: function () {
        this.$store.commit(MutationNames.ChangeStateFigures)
      },
      ChangeStateCitations: function () {
        this.$store.commit(MutationNames.ChangeStateCitations)
      },
      existCitation: function (citation) {
        var exist = false
        this.$store.getters[GetterNames.GetCitationsList].forEach(function (item, index) {
          if (item['source_id'] == citation.source_id) {
            exist = true
          }
        })
        return exist
      },

      copyCompareContent: function () {
        if (window.getSelection) {
          if (window.getSelection().toString().length > 0) {
            this.record.content.text += window.getSelection().toString()
            this.autoSave()
          }
        }
      },

      addCitation: function (cursorPosition) {
        let that = this

        that.record.content.text = [that.record.content.text.slice(0, cursorPosition),
          document.querySelector('[data-panel-name="pinboard"]').getAttribute('data-clipboard'),
          that.record.content.text.slice(cursorPosition)].join('')

        if (that.newRecord) {
          let ajaxUrl = `/contents/${that.record.content.id}`
          if (that.record.content.id == '') {
            that.$http.post(ajaxUrl, that.record).then(response => {
              this.$store.commit(MutationNames.AddToRecentContents, response.body)
              that.record.content.id = response.body.id
              that.newRecord = false
              that.createCitation()
            })
          }
        } else {
          that.update()
          that.createCitation()
        }
      },

      createCitation: function () {
        let
          sourcePDF = document.getElementById('pdfViewerContainer').dataset.sourceid
        if (sourcePDF == undefined) return
        this.currentSourceID = sourcePDF

        let citation = {
          pages: '',
          citation_object_type: 'Content',
          citation_object_id: this.record.content.id,
          source_id: this.currentSourceID
        }
        if (this.existCitation(citation)) return

        AjaxCall('post', '/citations', citation).then(response => {
          this.$store.commit(MutationNames.AddCitationToList, response.body)
        }, response => {

        })
      },

      handleInput: function () {
        if (this.firstInput) {
          this.firstInput = false
        } else {
          this.autoSave()
        }
      },
      resetAutoSave: function () {
        clearTimeout(this.autosave)
        this.autosave = null
      },

      autoSave: function () {
        let that = this
        if (this.autosave) {
          this.resetAutoSave()
        }
        this.autosave = setTimeout(function () {
          that.update()
        }, 3000)
      },

      update: function () {
        this.resetAutoSave()

        if ((this.disabled) || (this.record.content.text == '')) return
        let ajaxUrl = `/contents/${this.record.content.id}`

        if (this.record.content.id == '') {
          AjaxCall('post', ajaxUrl, this.record).then(response => {
            this.record.content.id = response.body.id
            this.$store.commit(MutationNames.AddToRecentContents, response.body)
            this.$store.commit(MutationNames.SetContentSelected, response.body)
          })
        } else {
          AjaxCall('patch', ajaxUrl, this.record).then(response => {
            this.$store.commit(MutationNames.AddToRecentContents, response.body)
          })
        }
      },

      loadContent: function () {
        if (this.disabled) return

        let
          ajaxUrl = `/contents/filter.json?otu_id=${this.otu.id}&topic_id=${this.topic.id}`

        this.firstInput = true
        this.resetAutoSave()
        AjaxCall('get', ajaxUrl).then(response => {
          if (response.body.length > 0) {
            this.record.content.id = response.body[0].id
            this.record.content.text = response.body[0].text
            this.record.content.topic_id = response.body[0].topic_id
            this.record.content.otu_id = response.body[0].otu_id
            this.newRecord = false
            this.$store.commit(MutationNames.SetContentSelected, response.body[0])
          } else {
            this.record.content.text = ''
            this.record.content.id = ''
            this.record.content.topic_id = this.topic.id
            this.record.content.otu_id = this.otu.id
            this.$store.commit(MutationNames.SetContent, undefined)
            this.newRecord = true
          }
        })
        this.loadMarkwdown = false;
        this.$nextTick(() => {
          this.loadMarkwdown = true;
        })
      }
    }
  }
</script>
