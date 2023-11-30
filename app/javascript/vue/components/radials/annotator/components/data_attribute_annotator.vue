<template>
  <div class="data_attribute_annotator">
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      :klass="objectType"
      :custom-list="{ all }"
      :lock-view="false"
      :filter-ids="list.map((item) => item.controlled_vocabulary_term_id)"
      @selected="
        ($event) => {
          predicate = $event
        }
      "
      v-model="predicate"
    />
    <hr v-if="predicate" />
    <SmartSelectorItem
      :item="predicate"
      @unset="() => (predicate = undefined)"
    />

    <textarea
      v-model="value"
      class="separate-bottom"
      placeholder="Value"
    />

    <div class="horizontal-left-content gap-small margin-small-bottom">
      <VBtn
        medium
        color="create"
        :disabled="!validateFields"
        @click="saveDataAttribute()"
      >
        {{ selectedDataAttribute.id ? 'Update' : 'Create' }}
      </VBtn>
      <VBtn
        medium
        color="primary"
        @click="resetForm"
      >
        New
      </VBtn>
    </div>
    <TableList
      :list="internalAttributes"
      :header="['Name', 'Value', '']"
      :attributes="['predicate_name', 'value']"
      edit
      target-citations="data_attributes"
      @edit="setDataAttribute"
      @delete="removeItem"
    />

    <div
      v-if="importList.length"
      class="margin-medium-top"
    >
      <h3>Import attributes</h3>
      <TableList
        :list="importList"
        :header="['Name', 'Value', '']"
        :attributes="['import_predicate', 'value']"
        :destroy="false"
      />
    </div>
  </div>
</template>

<script>
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { IMPORT_ATTRIBUTE } from '@/constants'
import { addToArray } from '@/helpers/arrays.js'
import CRUD from '../request/crud.js'
import AnnotatorExtend from '../components/annotatorExtend.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import TableList from './shared/tableList'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: {
    TableList,
    SmartSelector,
    SmartSelectorItem,
    VBtn
  },

  computed: {
    validateFields() {
      return this.predicate && this.value.length
    },

    importList() {
      return this.list.filter((item) => item.base_class === IMPORT_ATTRIBUTE)
    },

    internalAttributes() {
      return this.list.filter((item) => item.base_class !== IMPORT_ATTRIBUTE)
    }
  },

  data() {
    return {
      all: [],
      predicate: undefined,
      value: '',
      selectedDataAttribute: {}
    }
  },

  created() {
    ControlledVocabularyTerm.where({ type: ['Predicate'] }).then((response) => {
      this.all = response.body
    })
  },

  methods: {
    resetForm() {
      this.predicate = undefined
      this.value = ''
      this.selectedDataAttribute = {}
    },

    saveDataAttribute() {
      const payload = {
        id: this.selectedDataAttribute.id,
        type: 'InternalAttribute',
        value: this.value,
        controlled_vocabulary_term_id: this.predicate.id,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }

      const request = payload.id
        ? this.update(`/data_attributes/${payload.id}`, {
            data_attribute: payload
          })
        : this.create('/data_attributes', { data_attribute: payload })

      request.then(({ body }) => {
        addToArray(this.list, body)
        this.resetForm()
      })
    },

    setDataAttribute(dataAttribute) {
      this.selectedDataAttribute = dataAttribute
      this.predicate = dataAttribute.controlled_vocabulary_term
      this.value = dataAttribute.value
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
  .data_attribute_annotator {
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      min-height: 100px;
    }

    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
