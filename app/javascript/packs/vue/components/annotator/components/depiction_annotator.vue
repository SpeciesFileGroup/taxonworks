<template>
  <div class="depiction_annotator">
    <div class="field" v-if="depiction">
      <div class="separate-bottom">
        <img
          :src="depiction.image.result.alternatives.medium.url"
          :style="{
            width: `${depiction.image.result.alternatives.medium.width}px`,
            height: `${depiction.image.result.alternatives.medium.height}px`
          }"
        >
      </div>
      <div class="field">
        <input class="normal-input" type="text" v-model="depiction.figure_label" placeholder="Label">
      </div>
      <textarea class="normal-input separate-bottom" type="text" v-model="depiction.caption" placeholder="Caption"/>
      <div>
        <button type="button" class="normal-input button button-submit" @click="updateFigure()">Update</button>
        <button type="button" class="normal-input button button-default" @click="depiction = undefined">New</button>
      </div>
    </div>
    <div v-else>
      <dropzone class="dropzone-card separate-bottom" @vdropzone-sending="sending" @vdropzone-success="success" ref="figure" id="figure" url="/depictions" :use-custom-dropzone-options="true" :dropzone-options="dropzone"/>
      <display-list label="object_tag" :list="list" :edit="true" @edit="depiction = $event" @delete="removeItem" class="list"/>
    </div>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import displayList from './displayList.vue'
import dropzone from '../../dropzone.vue'
import annotatorExtend from '../components/annotatorExtend.js'

export default {
  mixins: [CRUD, annotatorExtend],
  components: {
    dropzone,
    displayList
  },
  data: function () {
    return {
      depiction: undefined,
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here to add figures',
        acceptedFiles: 'image/*'
      }
    }
  },
  methods: {
	        'success': function (file, response) {
	        	this.list.push(response)
	        	this.$refs.figure.removeFile(file)
	        },
	        'sending': function (file, xhr, formData) {
	          	formData.append('depiction[annotated_global_entity]', decodeURIComponent(this.globalId))
	        },
	        updateFigure () {
	        	this.update(`/depictions/${this.depiction.id}`, { depiction: this.depiction }).then(response => {
	        		this.$set(this.list, this.list.findIndex(element => this.depiction.id == element.id), response.body)
	        		this.depiction = undefined
	        	})
	        }
  }
}
</script>

<style type="text/css" lang="scss">
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
