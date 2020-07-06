<template>
  <td>
    <template v-if="importedCount">
      <a
        v-if="importedCount === 1"
        v-for="(item, key) in importedObjects"
        :key="key"
        :href="loadTask(key, item)"
        target="_blank"
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
            <a
              :href="loadTask(key, item)"
              target="_blank">{{ key }}
            </a>
          </li>
        </ul>
      </modal-component>
    </template>
    <template v-else>
      <template v-if="importedErrors">
        <modal-component
          v-if="showErrors"
          @close="showErrors = false">
          <h3 slot="header">Errors</h3>
          <div slot="body">
            <template v-for="(messages, typeError) in importedErrors.messages">
              <span
                :key="typeError"
                class="soft_validation"
                data-icon="warning">
                {{ typeError }}
              </span>
              <ul>
                <li
                  v-for="error in messages"
                  v-html="error"/>
              </ul>
            </template>
          </div>
        </modal-component>
        <a
          class="red"
          @click="showErrors = true"
          v-html="row.status"/>
      </template>
      <span
        v-else
        v-html="row.status"/>
    </template>
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
    importedErrors () {
      return this.row.metadata.error_data
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
      showModal: false,
      showErrors: false
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
