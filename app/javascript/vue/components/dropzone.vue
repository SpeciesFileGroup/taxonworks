<template>
  <form
    ref="dropzoneRef"
    :action="url"
    class="dropzone vue-dropzone"
  >
    <slot />
  </form>
</template>

<script setup>
import {
  computed,
  onMounted,
  onBeforeUnmount,
  useTemplateRef,
  watch
} from 'vue'

import { isJSON } from '@/helpers/objects'

const props = defineProps({
  url: {
    type: String,
    required: true
  },
  clickable: {
    type: Boolean,
    default: true
  },
  addRemoveButton: {
    type: Boolean,
    default: true
  },
  acceptedFileTypes: {
    type: String
  },
  thumbnailHeight: {
    type: Number,
    default: 200
  },
  thumbnailWidth: {
    type: Number,
    default: 200
  },
  showRemoveLink: {
    type: Boolean,
    default: true
  },
  maxFileSizeInMB: {
    type: Number,
    default: 512
  },
  maxNumberOfFiles: {
    type: Number,
    default: 5
  },
  autoProcessQueue: {
    type: Boolean,
    default: true
  },
  useFontAwesome: {
    type: Boolean,
    default: false
  },
  headers: {
    type: Object
  },
  timeout: {
    type: Number,
    default: 1800000
  },
  language: {
    type: Object,
    default: () => ({
      dictDefaultMessage: '<br>Drop files here to upload',
      dictCancelUpload: 'Cancel upload',
      dictCancelUploadConfirmation:
        'Are you sure you want to cancel this upload?',
      dictFallbackMessage:
        'Your browser does not support drag and drop file uploads.',
      dictFallbackText:
        'Please use the fallback form below to upload your files like in the olden days.',
      dictFileTooBig:
        'File is too big ({{filesize}}MiB). Max filesize: {{maxFilesize}}MiB.',
      dictInvalidFileType: "You can't upload files of this type.",
      dictMaxFilesExceeded:
        'You can not upload any more files. (max: {{maxFiles}})',
      dictRemoveFile: 'Remove',
      dictRemoveFileConfirmation: null,
      dictResponseError: 'Server responded with {{statusCode}} code.'
    })
  },
  useCustomDropzoneOptions: {
    type: Boolean,
    default: false
  },
  dropzoneOptions: {
    type: Object
  }
})

const emit = defineEmits([
  'vdropzone-thumbnail',
  'vdropzone-file-added',
  'vdropzone-removed-file',
  'vdropzone-success',
  'vdropzone-success-multiple',
  'vdropzone-error',
  'vdropzone-sending',
  'vdropzone-sending-multiple',
  'vdropzone-queue-complete'
])

const dropzoneRef = useTemplateRef('dropzoneRef')
let dropzone = null

const defaultConfiguration = computed(() => ({
  maxFilesize: props.maxFileSizeInMB,
  timeout: props.timeout
}))

onMounted(() => {
  Dropzone.autoDiscover = false

  const config = props.useCustomDropzoneOptions
    ? Object.assign({}, defaultConfiguration.value, props.dropzoneOptions)
    : {
        clickable: props.clickable,
        timeout: props.timeout,
        thumbnailWidth: props.thumbnailWidth,
        thumbnailHeight: props.thumbnailHeight,
        maxFiles: props.maxNumberOfFiles,
        maxFilesize: props.maxFileSizeInMB,
        acceptedFiles: props.acceptedFileTypes,
        autoProcessQueue: props.autoProcessQueue,
        headers: props.headers,
        previewTemplate:
          '<div class="dz-preview dz-file-preview">  <div class="dz-image" style="width:' +
          thumbnailWidth +
          'px;height:' +
          thumbnailHeight +
          'px"><img data-dz-thumbnail /></div>  <div class="dz-details">    <div class="dz-size"><span data-dz-size></span></div>    <div class="dz-filename"><span data-dz-name></span></div>  </div>  <div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div>  <div class="dz-error-message"><span data-dz-errormessage></span></div>  <div class="dz-success-mark">' +
          ' </div>  <div class="dz-error-mark">' +
          '</div></div>',
        dictDefaultMessage: props.language.dictDefaultMessage,
        dictCancelUpload: props.language.dictCancelUpload,
        dictCancelUploadConfirmation:
          props.language.dictCancelUploadConfirmation,
        dictFallbackMessage: props.language.dictFallbackMessage,
        dictFallbackText: props.language.dictFallbackText,
        dictFileTooBig: props.language.dictFileTooBig,
        dictInvalidFileType: props.language.dictInvalidFileType,
        dictMaxFilesExceeded: props.language.dictMaxFilesExceeded,
        dictRemoveFile: props.language.dictRemoveFile,
        dictRemoveFileConfirmation: props.language.dictRemoveFileConfirmation,
        dictResponseError: props.language.dictResponseError
      }

  dropzone = new Dropzone(dropzoneRef.value, config)

  dropzone.on('thumbnail', function (file) {
    emit('vdropzone-thumbnail', file)
  })
  dropzone.on('removedfile', function (file) {
    emit('vdropzone-removed-file', file)
  })
  dropzone.on('success', function (file, response) {
    emit('vdropzone-success', file, response)
  })
  dropzone.on('successmultiple', function (file, response) {
    emit('vdropzone-success-multiple', file, response)
  })
  dropzone.on('sending', function (file, xhr, formData) {
    emit('vdropzone-sending', file, xhr, formData)
  })
  dropzone.on('sendingmultiple', function (file, xhr, formData) {
    emit('vdropzone-sending-multiple', file, xhr, formData)
  })
  dropzone.on('queuecomplete', function (file, xhr, formData) {
    emit('vdropzone-queue-complete', file, xhr, formData)
  })
  dropzone.on('addedfile', function (file) {
    if (props.addRemoveButton) {
      makeRemoveButton(file)
    }

    emit('vdropzone-file-added', file)
  })

  dropzone.on('error', function (file, error, xhr) {
    const errorElements = dropzoneRef.value.querySelectorAll(
      '.dz-error-message span'
    )

    errorElements[errorElements.length - 1].innerHTML = isJSON(error)
      ? Object.entries(error)
          .map((e) => e.join(': '))
          .join('<br><br>')
      : error
    emit('vdropzone-error', file, error, xhr)
  })
})

function makeRemoveButton(file) {
  const removeButton = Dropzone.createElement(
    '<button class="button btn-primary btn button-circle btn-delete dz-remove-button" type="button"></button>'
  )

  removeButton.addEventListener('click', (e) => {
    e.preventDefault()
    e.stopPropagation()

    dropzone.removeFile(file)
  })

  file.previewElement.appendChild(removeButton)
}

function setOption(option, value) {
  dropzone.options[option] = value
}
function removeAllFiles() {
  dropzone.removeAllFiles(true)
}
function processQueue() {
  dropzone.processQueue()
}
function removeFile(file) {
  dropzone.removeFile(file)
}
function getQueuedFiles() {
  return dropzone.getQueuedFiles()
}

function getDropzone() {
  return dropzone
}

defineExpose({
  getDropzone,
  getQueuedFiles,
  processQueue,
  removeAllFiles,
  removeFile,
  setOption
})

watch(
  () => props.dropzoneOptions,
  () => {
    if (dropzone) {
      Object.assign(
        dropzone.options,
        defaultConfiguration.value,
        props.dropzoneOptions
      )
    }
  },
  { deep: true }
)

onBeforeUnmount(() => {
  dropzone.destroy()
})
</script>

<style>
.dz-remove-button {
  position: absolute;
  cursor: pointer !important;
  bottom: 12px;
  right: 12px;
  z-index: 30;
  box-shadow: none;
}
</style>
