<template>
  <div class="documentation_annotator">
    <div class="separate-bottom">
      <div class="switch-radio">
        <template
        v-for="(item, index) in optionList">
          <input
            v-model="display"
            :value="index"
            :id="`alternate_values-picker-${index}`"
            name="alternate_values-picker-options"
            type="radio"
            class="normal-input button-active"
          >
          <label
            :for="`alternate_values-picker-${index}`"
            class="capitalize">{{ item }}</label>
        </template>
      </div>
    </div>
    <div class="margin-medium-bottom">
      <label>
        <input
          v-model="isPublic"
          type="checkbox">
          Is public?
      </label>
    </div>
    <div
      class="field"
      v-if="display == 0">
      <dropzone
        class="dropzone-card"
        @vdropzone-sending="sending"
        @vdropzone-success="success"
        ref="figure"
        id="figure"
        url="/documentation"
        :use-custom-dropzone-options="true"
        :dropzone-options="dropzone"/>
    </div>

    <div v-if="display == 1">
      <autocomplete
        class="field"
        url="/documents/autocomplete"
        label="label"
        min="2"
        placeholder="Select a document"
        @getItem="documentation.document_id = $event.id"
        param="term"/>
      <button
        @click="createNew()"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button">Create
      </button>
    </div>

    <display-list
      label="object_tag"
      :list="list"
      :pdf="true"
      download="document.file_url"
      @delete="removeItem"
      class="list"/>
  </div>
</template>
<script>

  import CRUD from '../request/crud.js'
  import annotatorExtend from '../components/annotatorExtend.js'
  import Autocomplete from 'components/autocomplete.vue'
  import Dropzone from 'components/dropzone.vue'
  import DisplayList from 'components/displayList.vue'

  export default {
    mixins: [CRUD, annotatorExtend],
    components: {
      DisplayList,
      Autocomplete,
      Dropzone
    },
    computed: {
      validateFields() {
        return this.documentation.document_id
      }
    },
    data: function () {
      return {
        display: 0,
        optionList: ['drop', 'pick', 'pinboard'],
        list: [],
        documentation: this.newDocumentation(),
        isPublic: undefined,
        dropzone: {
          timeout: 0,
          paramName: 'documentation[document_attributes][document_file]',
          url: '/documentation',
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          },
          dictDefaultMessage: 'Drop documents here',
          acceptedFiles: 'application/pdf, text/plain'
        }
      }
    },
    methods: {
      newDocumentation() {
        return {
          document_id: null,
          annotated_global_entity: decodeURIComponent(this.globalId)
        }
      },
      createNew() {
        this.create('/documentation', {documentation: this.documentation}).then(response => {
          this.list.push(response.body)
          this.documentation = this.newDocumentation()
        })
      },
      'success': function (file, response) {
        this.list.push(response)
        this.$refs.figure.removeFile(file)
      },
      'sending': function (file, xhr, formData) {
        formData.append('documentation[annotated_global_entity]', decodeURIComponent(this.globalId))
        if (this.isPublic)
          formData.append('documentation[document_attributes][is_public]', this.isPublic)
      },
      updateFigure() {
        this.update(`/depictions/${this.depiction.id}`, this.depiction).then(response => {
          this.$set(this.list, this.list.findIndex(element => this.depiction.id == element.id), response.body)
          this.depiction = undefined
        })
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
