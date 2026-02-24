<template>
  <div>
    <VSpinner
      v-if="!store.source.id"
      :show-spinner="false"
      legend="Save source first to upload documents"
    />
    <div class="content">
      <div class="separate-bottom">
        <div class="switch-radio">
          <VSwitch
            class="full_width"
            v-model="TabSelected"
            :options="Object.keys(documentComponents)"
          />
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

      <component
        :source="store.source"
        :is-public="isPublic"
        :is="documentComponents[TabSelected]"
      />

      <table class="full_width margin-medium-top">
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
            v-for="item in store.documentation"
            :key="item.id"
            class="contextMenuCells"
          >
            <td class="full_width">
              <span
                class="word_break"
                v-html="item.document.object_tag"
              />
            </td>
            <td>
              <input
                type="checkbox"
                :checked="item.document.is_public"
                @click="changeIsPublicState(item)"
              />
            </td>
            <td>{{ item.updated_at }}</td>
            <td>
              <div class="flex-wrap-row gap-xsmall">
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
                  color="destroy"
                  @click="removeDocumentation(item)"
                >
                  <VIcon
                    color="white"
                    x-small
                    name="trash"
                  />
                </VBtn>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useSourceStore } from '../store'
import PdfButton from '@/components/ui/Button/ButtonPdf.vue'
import VSpinner from '@/components/ui/VSpinner'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import VSwitch from '@/components/ui/VSwitch'
import PickComponent from './documents/pick'
import DropComponent from './documents/drop.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const documentComponents = {
  Drop: DropComponent,
  Pick: PickComponent
}

const TabSelected = ref('Drop')
const isPublic = ref(false)

const store = useSourceStore()

function changeIsPublicState(documentation) {
  const data = {
    id: documentation.document_id,
    is_public: !documentation.document.is_public
  }
  store.saveDocumentation(data)
}

function removeDocumentation(documentation) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    store.removeDocumentation(documentation)
  }
}
</script>
