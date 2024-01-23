<template>
  <div class="documentation_annotator">
    <div class="separate-bottom">
      <VSwitch
        :options="Object.values(TABS)"
        v-model="tabSelected"
      />
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
      v-if="tabSelected === TABS.Drop"
    >
      <Dropzone
        class="dropzone-card"
        ref="figureRef"
        id="figure"
        url="/documentation"
        use-custom-dropzone-options
        :dropzone-options="DROPZONE_CONFIGURATION"
        @vdropzone-sending="sending"
        @vdropzone-success="success"
      />
    </div>

    <div v-if="tabSelected === TABS.Pick">
      <Autocomplete
        class="field"
        url="/documents/autocomplete"
        label="label"
        min="2"
        placeholder="Select a document"
        param="term"
        @get-item="({ id }) => (documentation.document_id = id)"
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
            <div class="horizontal-right-content gap-xsmall">
              <RadialAnnotator :global-id="item.global_id" />
              <PdfButton :pdf="item.document" />
              <VBtn
                circle
                class="circle-button"
                color="primary"
                :download="item.document.object_tag"
                :href="item.document.file_url"
              >
                <VIcon
                  color="white"
                  x-small
                  name="download"
                />
              </VBtn>
              <VBtn
                circle
                class="circle-button"
                color="destroy"
                @click="confirmDelete(item)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script setup>
import { computed, ref } from 'vue'
import { Documentation, Document } from '@/routes/endpoints'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import Dropzone from '@/components/dropzone.vue'
import PdfButton from '@/components/pdfButton.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import VIcon from '@/components/ui/VIcon/index'
import VBtn from '@/components/ui/VBtn/index'
import VSwitch from '@/components/switch.vue'
import { removeFromArray } from '@/helpers'

const DROPZONE_CONFIGURATION = {
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

const TABS = {
  Drop: 'drop',
  Pick: 'pick'
}

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update-count'])

const list = ref([])
const documentation = ref(newDocumentation())
const isPublic = ref(false)
const figureRef = ref()
const tabSelected = ref(TABS.Drop)

const validateFields = computed(() => documentation.value.document_id)

function newDocumentation() {
  return {
    document_id: null,
    documentation_object_id: props.objectId,
    documentation_object_type: props.objectType
  }
}

function createNew() {
  Documentation.create({ documentation: documentation.value }).then(
    ({ body }) => {
      list.value.push(body)
      documentation.value = newDocumentation()
      emit('update-count', list.value.length)
    }
  )
}

function success(file, response) {
  list.value.push(response)
  figureRef.value.removeFile(file)
}

function sending(file, xhr, formData) {
  formData.append('documentation[documentation_object_id]', props.objectId)
  formData.append('documentation[documentation_object_type]', props.objectType)
  if (isPublic.value) {
    formData.append(
      'documentation[document_attributes][is_public]',
      isPublic.value
    )
  }
}

function changeIsPublicState(index, documentation) {
  const payload = {
    document: {
      id: documentation.document_id,
      is_public: !documentation.document.is_public
    }
  }

  Document.update(documentation.document_id, payload).then(({ body }) => {
    list.value[index].is_public = body.is_public
  })
}

function removeItem(item) {
  Documentation.destroy(item.id).then((_) => {
    removeFromArray(list.value, item)
    emit('update-count', list.value.length)
  })
}

function confirmDelete(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    removeItem(item)
  }
}

Documentation.where({
  documentation_object_id: props.objectId,
  documentation_object_type: props.objectType,
  per: 500
}).then(({ body }) => {
  list.value = body
})
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
