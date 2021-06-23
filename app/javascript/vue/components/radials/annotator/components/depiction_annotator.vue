<template>
  <div class="depiction_annotator">
    <div
      class="field"
      v-if="depiction"
    >
      <div class="separate-bottom">
        <img
          :src="depiction.image.alternatives.medium.image_file_url"
          :style="{
            width: `${depiction.image.alternatives.medium.width}px`,
            height: `${depiction.image.alternatives.medium.height}px`
          }"
        >
      </div>
      <div class="field">
        <input
          class="normal-input"
          type="text"
          v-model="depiction.figure_label"
          placeholder="Label"
        >
      </div>
      <div class="field">
        <textarea
          class="normal-input"
          type="text"
          v-model="depiction.caption"
          placeholder="Caption"
        />
      </div>
      <label>
        <input
          type="checkbox"
          v-model="depiction.is_metadata_depiction"
        >
        Is data depiction
      </label>
      <div class="separate-top separate-bottom">
        <h4>Move to</h4>
        <ul class="no_bullets">
          <li
            v-for="type in objectTypes"
            :key="type.value"
          >
            <label>
              <input
                type="radio"
                name="depiction-type"
                v-model="selectedType"
                :value="type"
              >
              {{ type.label }}
            </label>
          </li>
        </ul>
        <div
          v-if="selectedType && !selectedObject"
          class="separate-top"
        >
          <autocomplete
            v-if="selectedType.value != 'Otu'"
            :disabled="!selectedType"
            :url="selectedType.url"
            label="label_html"
            :placeholder="`Select a ${selectedType.label.toLowerCase()}`"
            :clear-after="true"
            @getItem="selectedObject = $event"
            param="term"
          />
          <otu-picker
            v-else
            :clear-after="true"
            @getItem="selectedObject = $event"
          />
        </div>
        <div
          v-if="selectedObject"
          class="horizontal-left-content"
        >
          <span v-html="selectedObject.label_html" />
          <span
            class="circle-button button-default btn-undo"
            @click="selectedObject = undefined"
          />
        </div>
      </div>

      <div>
        <button
          type="button"
          class="normal-input button button-submit margin-small-right"
          @click="updateFigure()"
        >
          Update
        </button>
        <button
          type="button"
          class="normal-input button button-default"
          @click="depiction = undefined"
        >
          Back
        </button>
      </div>
    </div>
    <div v-else>
      <smart-selector
        model="images"
        :autocomplete="false"
        :search="false"
        :target="objectType"
        :add-tabs="['new', 'filter']"
        @selected="createDepiction">
        <template #new>
          <dropzone
            class="dropzone-card separate-bottom"
            @vdropzone-sending="sending"
            @vdropzone-success="success"
            ref="figure"
            url="/depictions"
            :use-custom-dropzone-options="true"
            :dropzone-options="dropzone"
          />
        </template>
        <template #filter>
          <div class="horizontal-left-content align-start">
            <filter-image
              @result="loadList"/>
            <div class="margin-small-left flex-wrap-row">
              <div
                v-for="image in filterList"
                :key="image.id"
                class="thumbnail-container margin-small cursor-pointer"
                @click="createDepiction(image)">
                <img
                  :width="image.alternatives.thumb.width"
                  :height="image.alternatives.thumb.height"
                  :src="image.alternatives.thumb.image_file_url">
              </div>
            </div>
          </div>
        </template>
      </smart-selector>
      <label>
        <input
          type="checkbox"
          v-model="isDataDepiction"
        >
        Is data depiction
      </label>
      <table class="full_width">
        <thead>
          <tr>
            <th>Image</th>
            <th>Is data</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in list"
            :key="item.id"
          >
            <td v-html="item.object_tag" />
            <td>{{ item.is_metadata_depiction }}</td>
            <td>
              <div class="horizontal-right-content middle">
                <radial-annotator
                  default-view="attributioan"
                  :global-id="item.image.global_id"
                />
                <span
                  class="button circle-button btn-edit button-submit"
                  @click="depiction = item" />
                <span
                  @click="confirmDelete(item)"
                  class="button circle-button btn-delete"
                />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import Dropzone from 'components/dropzone.vue'
import annotatorExtend from '../components/annotatorExtend.js'
import Autocomplete from 'components/ui/Autocomplete'
import OtuPicker from 'components/otu/otu_picker/otu_picker'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import FilterImage from 'tasks/images/filter/components/filter'
import SmartSelector from 'components/ui/SmartSelector'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    Dropzone,
    Autocomplete,
    FilterImage,
    OtuPicker,
    RadialAnnotator,
    SmartSelector
  },

  computed: {
    updateObjectType () {
      return this.selectedObject && this.selectedType
    }
  },

  data () {
    return {
      depiction: undefined,
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here to add figures',
        acceptedFiles: 'image/*,.heic'
      },
      objectTypes: [
        {
          value: 'Otu',
          label: 'Otu',
          url: '/otus/autocomplete'
        },
        {
          value: 'CollectingEvent',
          label: 'Collecting event',
          url: '/collecting_events/autocomplete'
        },
        {
          value: 'CollectionObject',
          label: 'Collection object',
          url: '/collection_objects/autocomplete'
        },
        {
          value: 'TaxonName',
          label: 'Taxon name',
          url: '/taxon_names/autocomplete'
        }
      ],
      isDataDepiction: false,
      selectedType: undefined,
      selectedObject: undefined,
      filterList: []
    }
  },

  mounted () {
    this.$options.components.RadialAnnotator = RadialAnnotator
  },

  methods: {
    success (file, response) {
      this.list.push(response)
      this.$refs.figure.removeFile(file)
    },

    sending (file, xhr, formData) {
      formData.append('depiction[annotated_global_entity]', decodeURIComponent(this.globalId))
      formData.append('depiction[is_metadata_depiction]', this.isDataDepiction)
    },

    updateFigure () {
      if (this.updateObjectType) {
        this.depiction.depiction_object_type = this.selectedType.value
        this.depiction.depiction_object_id = this.selectedObject.id
      }
      this.update(`/depictions/${this.depiction.id}`, { depiction: this.depiction }).then(response => {
        const index = this.list.findIndex(element => this.depiction.id === element.id)

        if (this.updateObjectType) {
          delete this.list[index]
        } else {
          this.list[index] = response.body
        }
        this.depiction = undefined
      })
    },

    confirmDelete (item) {
      if (window.confirm("You're trying to delete this record. Are you sure want to proceed?")) {
        this.removeItem(item)
      }
    },

    createDepiction (image) {
      const depiction = {
        image_id: image.id,
        annotated_global_entity: this.globalId,
        is_metadata_depiction: this.isDataDepiction
      }

      this.create('/depictions.json', { depiction: depiction }).then(({ body }) => {
        this.list.push(body)
        TW.workbench.alert.create('Depiction was successfully created.', 'notice')
      })
    },

    loadList (newList) {
      this.filterList = newList
    }
  }
}
</script>

<style lang="scss">
.radial-annotator {
  .depiction_annotator {
    button {
      min-width: 100px;
    }
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }
  }
}
</style>
