<template>
  <div class="panel" id="panel-editor">
    <div class="flexbox">
      <div class="left">
        <div class="title"><span><span v-if="topic">{{ topic.name }}</span> - <span v-if="otu" v-html="otu.object_tag"></span></span> <select-topic-otu></select-topic-otu></div>
        <div v-if="disabled" class="CodeMirror cm-s-paper CodeMirror-wrap"></div>
          <markdown-editor v-else class="edit-content" v-model="record.content.text" :configs="config" @input="handleInput" ref="contentText" v-on:dblclick.native="addCitation()"></markdown-editor>
      </div>
      <div v-if="compareContent && !preview" class="right">
        <div class="title"><span><span>{{ compareContent.topic.object_tag }}</span> - <span v-html="compareContent.otu.object_tag"></span></span></div>
        <div class="compare-toolbar middle"><button class="button button-close" @click="compareContent = undefined">Close compare</button></div>
        <div class="compare" @mouseup="copyCompareContent">{{ compareContent.text }}</div>
      </div>
    </div>
    <div class="flex-separate menu-content-editor">
      <div class="item flex-wrap-column middle menu-item menu-button" @click="update" :class="{ saving : autosave }"><span data-icon="savedb" class="big-icon"></span><span class="tiny_space">Save</span></div>
      <clone-content :class="{ disabled : !content }" class="item menu-item"></clone-content>
      <compare-content class="item menu-item"></compare-content>
      <div class="item flex-wrap-column middle menu-item menu-button" @click="ChangeStateCitations()" :class="{ active : activeCitations, disabled : citations < 1 }"><span data-icon="citation" class="big-icon"></span><span class="tiny_space">Citation</span></div>
      <citation-otu class="item menu-item"></citation-otu>
      <div class="item flex-wrap-column middle menu-item menu-button" @click="ChangeStateFigures()" :class="{ active : activeFigures, disabled : !content }"><span data-icon="new" class="big-icon"></span><span class="tiny_space">Figure</span></div>
    </div>
  </div>
</template>

<script>
    const cloneContent = require('./clone.vue');
    const compareContent = require('./compare.vue');
    const citationOtu = require('./compare.vue');
    const selectTopicOtu = require('./selectTopicOtu.vue');
    const markdownEditor = require('../../../components/markdown-editor.vue');
    const GetterNames = require('../store/getters/getters').GetterNames;
    const MutationNames = require('../store/mutations/mutations').MutationNames;

    export default {
      data: function() { 
        return {
          autosave: 0,
          firstInput: true,
          currentSourceID: '',
          newRecord: true,
          preview: false,
          compareContent: undefined,
          record: { 
            content: {
              otu_id: '',
              topic_id: '',
              text: '',
            }
          },
          config: {
            status: false,
            toolbar: ["bold", "italic", "code", "heading", "|", "quote", "unordered-list", "ordered-list", "|", "link", "table", "preview"],
            spellChecker: false,
          },

        }
      },
      components: {
        cloneContent,
        compareContent,
        citationOtu,
        markdownEditor,
        selectTopicOtu
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
        },            
      },      

      created: function() {
        var that = this;
        this.$on('addCloneCitation', function(itemText) {
          this.record.content.text += itemText;
          this.autoSave();
        });
        this.$on('showCompareContent', function(content){
          this.compareContent = content;
          this.preview = false;
        });
      },
      watch: {
        otu: function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        },
        topic: function(val, oldVal) {
          if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
            this.loadContent();
          }
        }            
      },
      methods: {
        ChangeStateFigures: function() {
          this.$store.commit(MutationNames.ChangeStateFigures);
        },
        ChangeStateCitations: function() {
          $store.commit(MutationNames.ChangeStateCitations)
        },        
        existCitation: function(citation) {
          var exist = false;
          this.$store.getters[GetterNames.GetCitationsList].forEach(function(item, index) {

          if(item['source_id'] == citation.source_id) {
              exist = true;
            }
          }); 
          return exist;
        },

        copyCompareContent: function() {
          if(window.getSelection) {
            if (window.getSelection().toString().length > 0) {
              this.record.content.text += window.getSelection().toString();
              this.autoSave();            
            }
          }        
        },

        addCitation: function() {
          var that = this;

          that.record.content.text = that.$refs.contentText.value + TW.views.shared.slideout.pdf.textCopy;
          if(that.newRecord) {
            var ajaxUrl = `/contents/${that.record.content.id}`;
            if(that.record.content.id == '') {
              that.$http.post(ajaxUrl, that.record).then(response => {
                this.$store.commit(MutationNames.AddToRecentContents, response.body);
                that.record.content.id = response.body.id;
                that.newRecord = false;
                that.createCitation();
               });            
            }
          }
          else {
            that.update();
            that.createCitation();
          }
        },

        createCitation: function() {
          var
            sourcePDF = document.getElementById("pdfViewerContainer").dataset.sourceid;          
          if(sourcePDF == undefined) return
          
          this.currentSourceID = sourcePDF;          

          var citation = {
            pages: '',
            citation_object_type: 'Content',  
            citation_object_id: this.record.content.id,          
            source_id: this.currentSourceID
          }
          if(this.existCitation(citation)) return

          this.$http.post('/citations', citation).then(response => {
            this.$store.commit(MutationNames.AddCitationToList, response.body);
          }, response => {

          });            
        },

        handleInput: function() {
          if (this.firstInput) {
            this.firstInput = false;
          }
          else {
            this.autoSave();
          }
        },
        resetAutoSave: function() {
          clearTimeout(this.autosave);
          this.autosave = null          
        },  

        autoSave: function() {
          var that = this;
          if(this.autosave) {
            this.resetAutoSave();
          }   
          this.autosave = setTimeout( function() {    
            that.update();  
          }, 3000);           
        },    

        update: function() {
          this.resetAutoSave()

          if ((this.disabled) || (this.record.content.text == "")) return
          var ajaxUrl = `/contents/${this.record.content.id}`;

          if(this.record.content.id == '') {
            this.$http.post(ajaxUrl, this.record).then(response => {
              this.record.content.id = response.body.id;
              this.$store.commit(MutationNames.AddToRecentContents, response.body);
              this.$store.commit(MutationNames.SetContentSelected, response.body);
             });            
          }
          else {
            this.$http.patch(ajaxUrl, this.record).then(response => {
              this.$store.commit(MutationNames.AddToRecentContents, response.body);
             });
          }          
        },

        loadContent: function() {
          if (this.disabled) return

          var
            ajaxUrl = `/contents/filter.json?otu_id=${this.otu.id}&topic_id=${this.topic.id}`;
          
          this.firstInput = true;
          this.resetAutoSave();
          this.$http.get(ajaxUrl).then(response => {      
            if(response.body.length > 0) {
              this.record.content.id = response.body[0].id;
              this.record.content.text = response.body[0].text;
              this.record.content.topic_id = response.body[0].topic_id;
              this.record.content.otu_id = response.body[0].otu_id;
              this.newRecord = false;
              this.$store.commit(MutationNames.SetContentSelected, response.body[0]);
            }
            else {
              this.record.content.text = '';
              this.record.content.id = '';              
              this.record.content.topic_id = this.topic.id;
              this.record.content.otu_id = this.otu.id;
              this.$store.commit(MutationNames.SetContent, undefined);
              this.newRecord = true;
            }
          }, response => {
            // error callback
          });          
        }
      }                
    };
</script>