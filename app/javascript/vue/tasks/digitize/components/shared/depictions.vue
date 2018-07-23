<template>
  <div class="depiction-container">
    <spinner
      v-if="false"
      :show-spinner="false"
      legend="Create a type specimen to upload images"/>
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      ref="depiction"
      :id="`depiction-${dropzoneId}`"
      url="/depictions"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
    <div
      class="flex-wrap-row"
      v-if="figuresList.length">
      <depictionImage
        v-for="item in figuresList"
        @delete="removeDepiction"
        :key="item.id"
        :depiction="item"/>
    </div>
  </div>

</template>

<script>

import ActionNames from '../../store/actions/actionNames'
import { GetDepictions, DestroyDepiction } from '../../request/resources.js'

import dropzone from '../../../../components/dropzone.vue'
import expand from '../../../../components/expand.vue'
import spinner from '../../../../components/spinner.vue'
import depictionImage from './depictionImage.vue'

export default {
  components: {
    depictionImage,
    dropzone,
    expand,
    spinner
  },
  props: {
    actionSave: {
      type: String,
      required: true
    },
    objectValue: {
      type: Object,
      required: true
    },
    objectType: {
      type: String,
      required: true
    }
  },
  data: function () {
    return {
      creatingType: false,
      displayBody: true,
      figuresList: [],
      dropzoneId: Math.random().toString(36).substr(2, 5),
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: false,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here to add figures',
        acceptedFiles: 'image/*'
      }
    }
  },
  watch: {
    objectValue (newVal, oldVal) {
      if (newVal.id && (newVal.id != oldVal.id)) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        GetDepictions(newVal.id).then(response => {
          this.figuresList = response
        })
      } else {
        this.figuresList = []
        this.$refs.depiction.setOption('autoProcessQueue', false)
      }
    }
  },
  methods: {
    'success': function (file, response) {
      this.figuresList.push(response)
      this.$refs.depiction.removeFile(file)
    },
    'sending': function (file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.objectValue.id)
      formData.append('depiction[depiction_object_type]', this.objectType)
    },
    'addedfile': function () {
      if (!this.objectValue.id && !this.creatingType) {
        this.creatingType = true
        this.$store.dispatch(ActionNames[this.actionSave]).then((response) => {
          var that = this
          setTimeout(function () {
            that.$refs.depiction.setOption('autoProcessQueue', true)
            that.$refs.depiction.processQueue()
            that.creatingType = false
          }, 500)
        }, () => {
          this.creatingType = false
        })
      }
    },
    removeDepiction (depiction) {
      if (window.confirm(`Are you sure want to proceed?`)) {
        DestroyDepiction(depiction.id).then(response => {
          TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
          this.figuresList.splice(this.figuresList.findIndex((figure) => { return figure.id == depiction.id }), 1)
        })
      }
    }
  }
}
</script>
<style scoped>
  .depiction-container {
    width: 500px;
    max-width: 500px;
  }
</style>