<template>
  <td>
    <template v-if="importedCount">
      <a
        v-if="importedCount === 1"
        v-for="(item, key) in importedObjects"
        :key="key"
        :href="loadTask(key, item)"
        v-html="row.status"/>
      <a
        v-else
        v-html="row.status"
        @click="openModal"/>
      <modal-component
        v-if="showModal"
        @close="showModal = false">
        <h3 slot="header">Imported objects</h3>
        <ul
          slot="body"
          class="no_billets">
          <li
            v-for="(item, key) in importedObjects"
            :key="(item + key)">
            <a :href="loadTask(key, item)">{{ key }}</a>
          </li>
        </ul>
      </modal-component>
    </template>
    <span
      v-else
      v-html="row.status"/>
  </td>
</template>

<script>

import { RouteNames } from 'routes/routes.js'
import ModalComponent from 'components/modal'

export default {
  components: {
    ModalComponent
  },
  props: {
    row: {
      type: Object,
      required: true
    }
  },
  computed: {
    importedObjects () {
      return this.row.metadata.imported_objects
    },
    importedCount () {
      return this.importedObjects ? Object.keys(this.importedObjects).length : 0
    }
  },
  data () {
    return {
      urlTask: {
        taxon_name: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
      },
      showModal: false
    }
  },
  methods: {
    loadTask (type, object) {
      return this.urlTask[type](object.id)
    },
    openModal () {
      this.showModal = true
    }
  }
}
</script>

<style>

</style>
