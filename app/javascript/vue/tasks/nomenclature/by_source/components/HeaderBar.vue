<template>
  <NavBar>
    <template v-if="source.id">
      <div class="source-text horizontal-left-content">
        <span>
          <span v-html="source.cached"/>
          <span class="separate-right">(Published on {{ source.cached_nomenclature_date }})</span>
        </span>
        <RadialObject :global-id="source.global_id"/>
        <RadialAnnotator :global-id="source.global_id"/>
        <pin-component
          v-if="source.id"
          class="circle-button"
          :object-id="source.id"
          :type="source.base_class"
        />
        <template 
          v-for="document in source.documents"
          :key="document.id">
          <a
            class="circle-button btn-download"
            :download="document.document_file_file_name"
            :title="document.document_file_file_name"
            :href="document.document_file"
          />
          <pdf-button :pdf="document" />
        </template>
      </div>
      <ul
        v-if="source.author_roles.length"
        class="no_bullets context-menu">
        <li 
          v-for="author in source.author_roles"
          :key="author.id">
          <a
            :href="`/people/${author.person.id}`"
            target="blank">
            {{ author.person.cached }}
          </a>
        </li>
      </ul>
    </template>
  </NavBar>
</template>
<script setup>

import RadialAnnotator from 'components/radials/annotator/annotator.vue';
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import PdfButton from 'components/pdfButton.vue'
import NavBar from 'components/layout/NavBar.vue'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { computed } from 'vue'
import { useStore } from 'vuex';

const store = useStore()
const source = computed(() => store.getters[GetterNames.GetSource])
const urlParams = new URLSearchParams(window.location.search)
const sourceId = urlParams.get('source_id')

if (/^\d+$/.test(sourceId)) {
  store.dispatch(ActionNames.LoadSource, sourceId)
}

</script>
<style lang="scss">
  #nomenclature-by-source-task {
    .nomen-source {
      min-height:100px;
      .source-text {
        font-size: 110%;
      }
      .vue-autocomplete-input {
        width: 400px !important;
      }
    }
  }
</style>
