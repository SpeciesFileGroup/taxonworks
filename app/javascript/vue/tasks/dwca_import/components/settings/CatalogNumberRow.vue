<template>
  <tr>
    <td v-html="displayData(row.institutionCode)" />
    <td v-html="displayData(row.collectionCode)" />
    <td class="full_width">
      <spinner-component
        v-if="isSaving"
        full-screen
        legend="Saving, please wait..."/>

      <autocomplete
        v-if="!namespace"
        class="full_width"
        placeholder="Search a namespace..."
        autofocus
        url="/namespaces/autocomplete"
        param="term"
        label="label_html"
        @get-item="addNamespace"
      />

      <div
        v-else
        class="flex-separate middle">
        <span>{{ namespaceLabel }}</span>
        <v-btn
          color="destroy"
          circle
          @click="setNamespace(null)"
        >
          <v-icon
            name="trash"
            x-small
          />
        </v-btn>
      </div>
    </td>
  </tr>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { UpdateCatalogueNumber } from '../../request/resources.js'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { Namespace } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    Autocomplete,
    SpinnerComponent,
    VBtn,
    VIcon
  },

  props: {
    row: {
      type: Object,
      required: true
    },

    datasetId: {
      type: [String, Number],
      required: true
    }
  },

  emits: ['update'],

  data () {
    return {
      edit: false,
      isSaving: false
    }
  },

  computed: {
    namespaceLabel () {
      return this.namespace ? `${this.namespace.name || this.namespace.label} (${this.namespace.short_name})` : ''
    },

    namespace () {
      return this.$store.getters[GetterNames.GetNamespaceFor](this.row.namespace_id)
    }
  },

  methods: {
    setNamespace (namespaceId) {
      const data = {
        import_dataset_id: this.datasetId,
        institutionCode: this.row.institutionCode,
        collectionCode: this.row.collectionCode,
        namespace_id: namespaceId
      }

      this.isSaving = true

      UpdateCatalogueNumber(data).then(_ => {
        this.isSaving = false
        this.$emit('update', data)
      })
    },

    async addNamespace ({ id }) {
      const namespace = (await Namespace.find(id)).body

      this.$store.commit(MutationNames.SetNamespace, namespace)
      this.setNamespace(namespace.id)
    },

    displayData (data) {
      return data || '<i>(blank/undefined)</i>'
    }
  }
}
</script>
