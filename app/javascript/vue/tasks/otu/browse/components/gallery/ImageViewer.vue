<template>
  <div class="depiction-thumb-container">
    <modal
      v-if="viewMode"
      @close="viewMode = false"
      :container-style="{ width: ((fullSizeImage ? depiction.image.width + 'px' : '500px') )}">
      <h3 slot="header">View</h3>
      <div slot="body">
        <div class="image-container">
          <template>
            <img
              class="img-maxsize img-fullsize"
              v-if="fullSizeImage"
              @click="fullSizeImage = false"
              :src="depiction.image.image_file_url">
            <img
              v-else
              class="img-maxsize img-normalsize"
              @click="fullSizeImage = true"
              :src="depiction.image.alternatives.medium.image_file_url"
              :height="depiction.image.alternatives.medium.height"
              :width="depiction.image.alternatives.medium.width">
          </template>
        </div>
        <div class="field separate-top">
          <input
            v-model="depiction.figure_label"
            type="text"
            placeholder="Label">
        </div>
        <div class="field separate-bottom">
          <textarea
            v-model="depiction.caption"
            rows="5"
            placeholder="Caption"/>
        </div>
        <div class="flex-separate">
          <div>
            <button
              type="button"
              class="button normal-input button-submit"
              @click="updateDepiction">
              Update
            </button>
          </div>
          <div class="horizontal-left-content">
            <ul class="context-menu no_bullets">
              <li class="horizontal-left-content">
                <radial-annotator
                  type="annotations"
                  :global-id="depiction.image.global_id"
                  @close="loadData"/>
                Image
              </li>
              <li class="horizontal-left-content">
                <radial-annotator
                  type="annotations"
                  :global-id="depiction.global_id"
                  @close="loadData"/>
                Depiction
              </li>
            </ul>
          </div>
        </div>
        <div class="flex-separate">
          <div>
            <h3 v-if="attributionsList.length">Attributions</h3>
            <template v-for="(attribution, index) in attributionsList">
              <ul class="no_bullets">
                <li v-for="persons in attribution"><span v-html="persons"/></li>
                <li v-if="attributions[index].copyright_year">
                  Copyright year: <b>{{ attributions[index].copyright_year }}</b>
                </li>
                <li v-if="attributions[index].license">
                  License: <b>{{ attributions[index].license }}</b>
                </li>
              </ul>
            </template>
          </div>
          <div>
            <h3 v-if="originalCitation">Original citation</h3>
            <span v-html="originalCitation"/>
          </div>
        </div>
      </div>
    </modal>
    <div class="depiction-thumb-image">
      <img
        class="img-thumb"
        @click="viewMode = true"
        :src="depiction.image.alternatives.thumb.image_file_url"
        :height="depiction.image.alternatives.thumb.height"
        :width="depiction.image.alternatives.thumb.width">
    </div>
  </div>
</template>
<script>

import Modal from 'components/modal.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import AjaxCall from 'helpers/ajaxCall'
import { capitalize } from 'helpers/strings.js'

const roleTypes = ['creator_roles', 'owner_roles', 'copyright_holder_roles', 'editor_roles']
const roleLabel = (role) => capitalize(role.replace('_roles', '').replaceAll('_', ' '))

export default {
  components: {
    Modal,
    RadialAnnotator
  },
  props: {
    depiction: {
      type: Object,
      required: true
    }
  },
  computed: {
    attributionsList () {
      return this.attributions.map(attr =>
        roleTypes.map(role =>
          attr[role] ? `${roleLabel(role)}: <b>${attr[role].map(item => item?.person?.object_tag || item.organization.name).join('; ')}</b>` : []).filter(arr => arr.length))
    },
    originalCitation () {
      return this.citations.filter(citation => citation.is_original).map(citation => [citation.source.cached, citation.pages].filter(item => item).join(':')).join('; ')
    }
  },
  data () {
    return {
      fullSizeImage: false,
      viewMode: false,
      attributions: [],
      citations: [],
      alreadyLoaded: false
    }
  },
  watch: {
    viewMode (newVal) {
      if (newVal && !this.alreadyLoaded) {
        this.alreadyLoaded = true
        this.loadData(this.depiction.image.id)
      }
    }
  },
  methods: {
    async loadData () {
      const imageId = this.depiction.image.id
      this.attributions = (await AjaxCall('get', `/images/${imageId}/attributions.json`)).body
      this.citations = (await AjaxCall('get', `/images/${imageId}/citations.json`)).body
    },
    updateDepiction () {
      const data = {
        caption: this.depiction.caption,
        figure_label: this.depiction.figure_label
      }
      AjaxCall('patch', `/depictions/${this.depiction.id}.json`, { depiction: data }).then(response => {
        TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
      })
    }
  }
}
</script>
<style lang="scss">

  .depiction-thumb-image {
    display: flex;
    align-items: center;
    width: 100px;
    height: 100px;
    border: 1px solid black;
  }

  .depiction-thumb-container {

    margin: 4px;

    .modal-container {
      max-width: 90vw;
      max-height: 90vh;
      overflow: auto;
    }

    .img-thumb {
      cursor: pointer;
    }

    .img-maxsize {
      transition: all 0.5s ease;
      max-width: 100%;
      max-height: 60vh;
    }

    .img-fullsize {
      cursor: zoom-out
    }

    .img-normalsize {
      cursor: zoom-in
    }

    .field {
      input, textarea {
        width: 100%
      }
    }

    .image-container {
      display: flex;
      justify-content: center;
    }
  }
</style>
