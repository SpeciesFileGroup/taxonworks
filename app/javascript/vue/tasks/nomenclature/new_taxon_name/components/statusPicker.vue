<template>
  <block-layout
    :warning="checkValidation"
    anchor="status"
    :spinner="!taxon.id">
    <template #header>
      <h3>Status</h3>
    </template>
    <template #body>
      <div v-if="classificationObject.id">
        <p class="inline">
          <span class="separate-right">Editing status: </span>
          <span v-html="classificationObject.object_tag"/>
          <span
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="classificationObject = {}"/>
        </p>
      </div>
      <classification-main
        @select="saveClassification"
        :created="getStatusCreated"
      />
      <ul
        v-if="!getStatusCreated.length && taxon.cached_is_valid"
        class="table-entrys-list">
        <li class="list-complete-item middle">
          <p>Valid as default</p>
        </li>
      </ul>
      <display-list
        @delete="removeStatus"
        @edit="classificationObject = $event"
        edit
        annotator
        :list="getStatusCreated"
        label="object_tag"/>
    </template>
  </block-layout>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import DisplayList from 'components/displayList.vue'
import BlockLayout from 'components/layout/BlockLayout'
import ClassificationMain from './Classification/ClassificationMain.vue'

const store = useStore()

const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const softValidation = computed(() => store.getters[GetterNames.GetSoftValidation].taxonStatusList.list)
const checkValidation = computed(() => !!softValidation.value.filter(item => getStatusCreated.value.find(({ id }) => id === item.instance.id)).length)
const getStatusCreated = computed(() => store.getters[GetterNames.GetTaxonStatusList].filter(item => item.type.split('::')[1] !== 'Latinized'))
const classificationObject = ref({})

const saveClassification = item => {
  const { id } = classificationObject.value
  const saveRequest = id
    ? store.dispatch(ActionNames.UpdateTaxonStatus, { ...item, id })
    : store.dispatch(ActionNames.AddTaxonStatus, item)

  saveRequest.then(_ => { store.commit(MutationNames.UpdateLastChange) })

  classificationObject.value = {}
}

const removeStatus = item => {
  store.dispatch(ActionNames.RemoveTaxonStatus, item)
}
</script>
