<template>
  <block-layout
    :warning="checkValidation"
    anchor="status"
    :spinner="!taxon.id">
    <template #header>
      <h3>Status</h3>
    </template>
    <template #body>
      <div v-if="editStatus">
        <p class="inline">
          <span class="separate-right">Editing status: </span>
          <span v-html="editStatus.object_tag"/>
          <span
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="editStatus = undefined"/>
        </p>
      </div>
      <classification-main
        @select="addEntry"
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
        @edit="editStatus = $event"
        edit
        annotator
        :list="getStatusCreated"
        label="object_tag"/>
    </template>
  </block-layout>
</template>

<script>
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import DisplayList from 'components/displayList.vue'
import BlockLayout from 'components/layout/BlockLayout'
import ClassificationMain from './Classification/ClassificationMain.vue'

export default {
  components: {
    ClassificationMain,
    BlockLayout,
    DisplayList
  },

  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    taxonRank () {
      return this.$store.getters[GetterNames.GetRankClass]
    },

    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].taxonStatusList.list
    },

    checkValidation () {
      return !!this.softValidation.filter(item => this.getStatusCreated.find(created => created.id === item.instance.id)).length
    },

    getStatusCreated () {
      return this.$store.getters[GetterNames.GetTaxonStatusList].filter(item => item.type.split('::')[1] !== 'Latinized')
    }
  },

  data () {
    return {
      editStatus: undefined
    }
  },

  methods: {
    removeStatus (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonStatus, item)
    },

    addEntry (item) {
      const saveRequest = this.editStatus
        ? this.$store.dispatch(ActionNames.UpdateTaxonStatus, item)
        : this.$store.dispatch(ActionNames.AddTaxonStatus, item)

      saveRequest.then(_ => { this.$store.commit(MutationNames.UpdateLastChange) })

      this.editStatus = undefined
    }
  }
}
</script>
