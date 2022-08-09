<template>
  <div class="">
    <h3>Recent</h3>
    <table-list
      :header="[...TABLE_HEADERS, '']"
      :attributes="TABLE_ATTRIBUTES"
      :list="list"
      edit
      @edit="store.dispatch(ActionNames.LoadExtract, $event.id)"
      @delete="store.dispatch(ActionNames.RemoveExtract, $event)"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import TableList from 'components/table_list'
import makeExtractList from '../helpers/makeExtractList'
import {
  TABLE_ATTRIBUTES,
  TABLE_HEADERS
} from '../const/table'


const store = useStore()
const list = computed(() => makeExtractList(store.getters[GetterNames.GetRecent]))

store.dispatch(ActionNames.LoadRecents)
</script>
