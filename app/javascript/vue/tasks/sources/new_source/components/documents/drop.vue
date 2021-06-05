<template>
  <div class="field">
    <dropzone
      class="dropzone-card"
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      ref="sourceDocument"
      id="source-document"
      url="/documentation"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"
    />
  </div>
</template>

<script>

import Dropzone from 'components/dropzone.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  components: {
    Dropzone
  },

  props: {
    isPublic: {
      type: Boolean,
      required: true
    },
    source: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      dropzone: {
        timeout: 0,
        maxFilesize: 512,
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

  computed: {
    list: {
      get () {
        return this.$store.getters[GetterNames.GetDocumentations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDocumentations, value)
      }
    }
  },

  methods: {
    success (file, response) {
      this.$store.commit(MutationNames.AddDocumentation, response)
      TW.workbench.alert.create('Documentation was successfully created.', 'notice')
      this.$refs.sourceDocument.removeFile(file)
    },

    sending (file, xhr, formData) {
      formData.append('documentation[annotated_global_entity]', decodeURIComponent(this.source.global_id))
      formData.append('documentation[document_attributes][is_public]', this.isPublic)
    }
  }
}
</script>
