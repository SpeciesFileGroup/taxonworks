<template>
  <div class="documentation_annotator">
    <div class="separate-bottom">
      <div class="switch-radio">
        <template v-for="(item, index) in optionList">
          <input
            v-model="display"
            :value="index"
            :id="`alternate_values-picker-${index}`"
            name="alternate_values-picker-options"
            type="radio"
            class="normal-input button-active"
          />
          <label
            :for="`alternate_values-picker-${index}`"
            class="capitalize"
            >{{ item }}</label
          >
        </template>
      </div>
    </div>
    <div class="margin-medium-bottom">
      <label>
        <input
          v-model="isPublic"
          type="checkbox"
        />
        Is public?
      </label>
    </div>
    <div
      class="field"
      v-if="display == 0"
    >
      <dropzone
        class="dropzone-card"
        @vdropzone-sending="sending"
        @vdropzone-success="success"
        ref="figure"
        id="figure"
        url="/documentation"
        :use-custom-dropzone-options="true"
        :dropzone-options="dropzone"
      />
    </div>

    <div v-if="display == 1">
      <autocomplete
        class="field"
        url="/documents/autocomplete"
        label="label"
        min="2"
        placeholder="Select a document"
        @getItem="documentation.document_id = $event.id"
        param="term"
      />
      <button
        @click="createNew()"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button"
      >
        Create
      </button>
    </div>

    <table>
      <thead>
        <tr>
          <th>Filename</th>
          <th>Is public</th>
          <th>Updated at</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in list"
          :key="item.id"
        >
          <td>
            <span
              class="word_break"
              v-html="item.document.object_tag"
            />
          </td>
          <td>
            <input
              type="checkbox"
              :checked="item.document.is_public"
              @click="changeIsPublicState(index, item)"
            />
          </td>
          <td>{{ item.updated_at }}</td>
          <td>
            <div class="horizontal-right-content">
              <radial-annotator :global-id="item.global_id" />
              <pdf-button :pdf="item.document" />
              <v-btn
                circle
                class="circle-button"
                color="primary"
                :download="item.document.object_tag"
                :href="item.document.file_url"
              >
                <v-icon
                  color="white"
                  x-small
                  name="download"
                />
              </v-btn>
              <v-btn
                circle
                class="circle-button"
                color="destroy"
                @click="confirmDelete(item)"
              >
                <v-icon
                  name="trash"
                  x-small
                />
              </v-btn>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import Autocomplete from 'components/ui/Autocomplete.vue'
import Dropzone from 'components/dropzone.vue'
import PdfButton from 'components/pdfButton.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import VIcon from 'components/ui/VIcon/index'
import VBtn from 'components/ui/VBtn/index'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    RadialAnnotator,
    Autocomplete,
    PdfButton,
    Dropzone,
    VBtn,
    VIcon
  },

  computed: {
    validateFields() {
      return this.documentation.document_id
    }
  },

  data() {
    return {
      display: 0,
      optionList: ['drop', 'pick', 'pinboard'],
      list: [],
      documentation: this.newDocumentation(),
      isPublic: undefined,
      dropzone: {
        maxFilesize: 512,
        timeout: 0,
        paramName: 'documentation[document_attributes][document_file]',
        url: '/documentation',
        headers: {
          'X-CSRF-Token': document
            .querySelector('meta[name="csrf-token"]')
            .getAttribute('content')
        },
        dictDefaultMessage: 'Drop documents here',
        acceptedFiles: 'application/pdf, text/plain'
      }
    }
  },

  created() {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },

  methods: {
    newDocumentation() {
      return {
        document_id: null,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }
    },

    createNew() {
      this.create('/documentation', { documentation: this.documentation }).then(
        (response) => {
          this.list.push(response.body)
          this.documentation = this.newDocumentation()
        }
      )
    },

    success(file, response) {
      this.list.push(response)
      this.$refs.figure.removeFile(file)
    },

    sending(file, xhr, formData) {
      formData.append(
        'documentation[annotated_global_entity]',
        decodeURIComponent(this.globalId)
      )
      if (this.isPublic) {
        formData.append(
          'documentation[document_attributes][is_public]',
          this.isPublic
        )
      }
    },

    changeIsPublicState(index, documentation) {
      const data = {
        id: documentation.document_id,
        is_public: !documentation.document.is_public
      }
      this.update(`/documents/${data.id}.json`, { document: data }).then(
        (response) => {
          this.list[index].is_public = response.body.is_public
        }
      )
    },

    confirmDelete(item) {
      if (
        window.confirm(
          "You're trying to delete this record. Are you sure want to proceed?"
        )
      ) {
        this.removeItem(item)
      }
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
  .documentation_annotator {
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }
    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
