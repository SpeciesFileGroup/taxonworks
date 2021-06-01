<template>
  <div id="cite_otus">
    <div class="flexbox">
      <div>
        <div class="flexbox">
          <div
            v-if="!disabled"
            class="panel item1 flex-wrap-row middle"
            id="delete-citation">
            <remove-citation/>
          </div>
          <div class="item item1 separate-right">
            <div>
              <div class="panel">
                <div
                  id="source-picker"
                  class="flex-separate horizontal-center-content content">
                  <div class="content full_width">
                    <div v-if="source">
                      <p v-html="source.object_tag"/>
                    </div>
                  </div>
                  <source-picker/>
                </div>
              </div>
              <div class="panel">
                <div
                  id="otu-picker"
                  class="horizontal-left-content content">
                  <div class="content full_width">
                    <div v-if="otu">
                      <h3 v-html="otu.object_tag"/>
                    </div>
                  </div>
                  <otu-picker/>
                </div>
              </div>
            </div>
            <div
              class="panel"
              v-if="!disabled">
              <topics-checklist/>
            </div>
          </div>
        </div>
      </div>
      <div
        id="recent_list"
        class="slide-panel slide-left slide-recent item item2 separate-left slide-recent"
        data-panel-position="relative"
        data-panel-open="true"
        data-panel-name="recent_list">
        <div class="slide-panel-header flex-separate">
          <span>Recent</span>
        </div>
        <div class="slide-panel-content">
          <source-citations/>
          <otu-citations/>
        </div>
      </div>
    </div>
  </div>
</template>
<script>

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

import removeCitation from './components/removeCitation.vue'
import OtuPicker from './components/otuPicker.vue'
import OtuCitations from './components/otuCitations.vue'
import TopicsChecklist from './components/topicsChecklist.vue'
import SourceCitations from './components/sourceCitations.vue'
import SourcePicker from './components/sourcePicker.vue'
import { Citation, Otu, Topic } from 'routes/endpoints'

export default {
  components: {
    removeCitation,
    OtuPicker,
    SourcePicker,
    OtuCitations,
    TopicsChecklist,
    SourceCitations
  },

  computed: {
    otu () {
      return this.$store.getters[GetterNames.GetOtuSelected]
    },
    source () {
      return this.$store.getters[GetterNames.GetSourceSelected]
    },
    disabled () {
      return this.$store.getters[GetterNames.ObjectsSelected]
    }
  },

  watch: {
    otu (val, oldVal) {
      if (val !== oldVal) {
        if (val != undefined) {
          this.loadOtuCitations()
        }
        if (!this.disabled) {
          this.loadCitations()
        }
      }
    },
    source (val, oldVal) {
      if (val !== oldVal) {
        if (val != undefined) {
          this.loadSourceCitations()
        }
        if (!this.disabled) {
          this.loadCitations()
        }
      }
    }
  },

  methods: {
    loadSourceCitations () {
      Citation.where({
        source_id: this.$store.getters[GetterNames.GetSourceSelected].id,
        citation_object_type: 'Otu'
      }).then(response => {
        if (response.body.length) {
          this.$store.commit(MutationNames.SetSourceCitationsList, response.body)
        }
      })
    },

    loadOtuCitations () {
      Citation.where({
        citation_object_type: 'Otu',
        citation_object_id: this.$store.getters[GetterNames.GetOtuSelected].id
      }).then(response => {
        if (response.body.length) {
          this.$store.commit(MutationNames.SetOtuCitationsList, response.body)
        }
      })
    },

    loadCitations () {
      const { commit, getters } = this.$store

      Otu.citations(this.$store.getters[GetterNames.GetOtuSelected].id).then(response => {
        commit(MutationNames.SetCitationsList, response.body)
      })

      Citation.where({
        source_id: this.$store.getters[GetterNames.GetSourceSelected].id,
        citation_object_type: 'Otu',
        citation_object_id: this.$store.getters[GetterNames.GetOtuSelected].id
      }).then(response => {
        if (response.body.length) {
          commit(MutationNames.SetCurrentCitation, response.body[0])
          commit(MutationNames.AddCitation, response.body[0])
          commit(MutationNames.SetTopicsSelected, response.body[0].citation_topics)
        } else {
          const citation = {
            citation_object_type: 'Otu',
            citation_object_id: getters[GetterNames.GetOtuSelected].id,
            source_id: getters[GetterNames.GetSourceSelected].id
          }

          Citation.create({ citation: citation }).then(response => {
            commit(MutationNames.SetCurrentCitation, response.body)
            commit(MutationNames.AddCitation, response.body)
            commit(MutationNames.AddToSourceList, response.body)
            commit(MutationNames.AddToOtuList, response.body)
            commit(MutationNames.SetTopicsSelected, response.body.citation_topics)
          })
        }
      })
    }
  },

  beforeCreate () {
    Topic.all().then(response => {
      this.$store.commit(MutationNames.SetTopicsList, response.body)
    })
  }
}
</script>
