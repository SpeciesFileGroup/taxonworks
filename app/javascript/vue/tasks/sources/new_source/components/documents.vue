<template>
  <div>
    <spinner-component
      v-if="!source.id"
      :show-spinner="false"
      legend="Save source first to upload documents"/>
    <div class="content">
      <div class="separate-bottom">
        <div class="switch-radio">
          <switch-component
            class="full_width"
            v-model="display"
            :options="optionList"/>
        </div>
      </div>
      <div class="margin-medium-bottom">
        <label>
          <input
            v-model="isPublic"
            type="checkbox"
          >
          Is public?
        </label>
      </div>

      <component
        :source="source"
        :is-public="isPublic"
        :is="componentView"/>

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
            v-for="item in list"
            :key="item.id"
            class="contextMenuCells">
            <td><span v-html="item.document.object_tag" /></td>
            <td>
              <input
                type="checkbox"
                :checked="item.document.is_public"
                @click="changeIsPublicState(item)"
              >
            </td>
            <td>{{ item.updated_at }}</td>
            <td>
              <div class="flex-wrap-row">
                <radial-annotator :global-id="item.global_id"/>
                <pdf-button :pdf="item.document"/>
                <v-btn
                  circle
                  class="circle-button"
                  color="primary"
                  :download="item.document.object_tag"
                  :href="item.document.file_url">
                  <v-icon
                    color="white"
                    x-small
                    name="download"/>
                </v-btn>
                <span
                  class="button circle-button btn-delete"
                  @click="removeDocumentation(item)"/>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>

import PdfButton from 'components/pdfButton.vue'
import SpinnerComponent from 'components/spinner'
import RadialAnnotator from 'components/radials/annotator/annotator'
import SwitchComponent from 'components/switch'
import PickComponent from './documents/pick'
import DropComponent from './documents/drop.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

export default {
  components: {
    PdfButton,
    PickComponent,
    RadialAnnotator,
    SwitchComponent,
    DropComponent,
    SpinnerComponent,
    VIcon,
    VBtn
  },

  data () {
    return {
      display: 'Drop',
      optionList: ['Drop', 'Pick'],
      isPublic: false
    }
  },

  computed: {
    componentView () {
      return `${this.display}Component`
    },

    source: {
      get () {
        return this.$store.getters[GetterNames.GetSource]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSource, value)
      }
    },

    list () {
      return this.$store.getters[GetterNames.GetDocumentations]
    }
  },

  methods: {
    changeIsPublicState (documentation) {
      const data = {
        id: documentation.document_id,
        is_public: !documentation.document.is_public
      }
      this.$store.dispatch(ActionNames.SaveDocumentation, data)
    },

    removeDocumentation (documentation) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$store.dispatch(ActionNames.RemoveDocumentation, documentation)
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
