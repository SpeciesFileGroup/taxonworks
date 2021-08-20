<template>
  <div class="identifier_annotator">
    <div>
      <div v-if="namespace">
        <div class="separate-bottom">
          <span class="capitalize">{{ namespace }}</span>
          <button
            type="button"
            @click="reset()">Change</button>
        </div>
        <fieldset>
          <legend>Type</legend>
          <div
            v-if="namespace != 'unknown'"
            class="switch-radio">
            <template v-for="item, index in barList">
              <input
                v-model="display"
                :value="item"
                :id="`alternate_values-picker-${index}`"
                name="alternate_values-picker-options"
                type="radio"
                class="normal-input button-active"
              >
              <label
                :for="`alternate_values-picker-${index}`"
                class="capitalize">{{ item }}
              </label>
            </template>
          </div>

          <div class="separate-top">
            <ul
              v-show="namespace != 'unknown'"
              class="no_bullets">
              <li v-for="item in typeList[namespace].common">
                <label class="capitalize">
                  <input
                    type="radio"
                    v-model="identifier.type"
                    :value="item">
                  {{ typeList[namespace].all[item].label }}
                </label>
              </li>
            </ul>

            <modal
              class="transparent-modal"
              v-if="display == 'show all'"
              @close="display = 'common'">
              <template #header>
                <h3>Types</h3>
              </template>
              <template #body>
                <ul>
                  <li
                    class="modal-list-item"
                    v-for="item, key in typeList[namespace].all">
                    <button
                      type="button"
                      :value="key"
                      @click="identifier.type = key, display = 'common'"
                      class="button button-default normal-input modal-button capitalize">
                      {{ item.label }}
                    </button>
                  </li>
                </ul>
              </template>
            </modal>
          </div>

          <p
            v-if="identifier.type"
            class="capitalize">Type: {{ typeList[namespace].all[identifier.type].label }}
          </p>
        </fieldset>
        <div>
          <spinner-component
            v-if="!isTypeSelected"
            :show-spinner="false"
            :show-legend="false"
          />
          <namespace-component
            v-show="isLocal"
            :object-type="objectType"
            @onLabelChange="namespaceSelectedLabel = $event"
            v-model="identifier.namespace_id"
          />

          <div class="field separate-top">
            <input
              class="normal-input identifier"
              placeholder="Identifier"
              type="text"
              v-model="identifier.identifier">
          </div>

          <p>
            <template v-if="isLocal">
              <span v-if="identifier.namespace_id"> {{ namespaceSelectedLabel }} </span>
              <span v-else> [ Select namespace ] </span>
            </template>
            <template>
              <span v-if="identifier.identifier && identifier.identifier.length"> {{ identifier.identifier }} </span>
              <span v-else> [ Provide identifier ] </span>
            </template>
          </p>

          <button
            @click="createNew()"
            :disabled="!validateFields"
            class="button normal-input button-submit separate-bottom"
            type="button">Create
          </button>
        </div>
      </div>

      <div
        v-else
        class="field">
        <ul class="no_bullets">
          <li v-for="type, key in typeList">
            <label class="capitalize">
              <input
                type="radio"
                v-model="namespace"
                :value="key">
              {{ key }}
            </label>
          </li>
        </ul>
      </div>
    </div>
    <table-list
      :list="list"
      :header="['Identifier', 'Type', '']"
      :attributes="['cached', 'type']"
      :annotator="false"
      @edit="data_attribute = $event"
      @delete="removeItem"/>
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../../components/annotatorExtend.js'
import Modal from 'components/ui/Modal.vue'
import TableList from 'components/table_list.vue'
import NamespaceComponent from './namespace'
import SpinnerComponent from 'components/spinner.vue'

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: {
    TableList,
    Modal,
    NamespaceComponent,
    SpinnerComponent
  },

  computed: {
    validateFields () {
      return this.identifier.identifier &&
              (this.identifier.type) &&
              ((this.namespace === 'local' && this.identifier.namespace_id) || (this.namespace !== 'local'))
    },
    isTypeSelected() {
      return this.identifier.type
    },
    isLocal() {
      return this.namespace === 'local'
    }
  },

  data () {
    return {
      namespaceSelectedLabel: '',
      showAll: false,
      display: 'common',
      barList: ['common', 'show all'],
      identifier: this.newIdentifier(),
      namespace: undefined,
      typeList: []
    }
  },

  watch: {
    namespace (newVal) {
      if (newVal === 'unknown') {
        this.identifier.type = this.typeList[newVal].common[0]
      }
    }
  },

  mounted () {
    this.getList('/identifiers/identifier_types').then(response => {
      this.typeList = response.body
    })
  },

  methods: {
    createArrayList (obj) {
      return Object.keys(obj).map((key) => ({
        value: key,
        label: obj[key].label
      }))
    },

    newIdentifier () {
      return {
        type: undefined,
        namespace_id: undefined,
        identifier: undefined,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }
    },

    createNew () {
      this.create('/identifiers', { identifier: this.identifier }).then(response => {
        this.list.push(response.body)
        this.namespace = undefined
        this.identifier = this.newIdentifier()
      })
    },

    reset () {
      this.identifier = this.newIdentifier()
      this.namespace = undefined
      this.display = 'common'
    },

    namespaceAlreadyCreated (namespace) {
      return this.list.find(item => namespace.id === item.namespace_id)
    }
  }
}
</script>
<style lang="scss">
.radial-annotator {
  .identifier_annotator {
    button {
      min-width: 100px;
    }
    .identifier {
      width: 100%;
    }
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }
    .vue-autocomplete-input, .input {
      width: 100%;
    }
    li {
      border-right: 0px;
      padding-left: 0px;
    }
    .modal-button {
      min-width: auto;
    }
    .modal-list-item {
      margin-top: 6px;
    }
    .switch-radio {
      label {
        width: 100%;
      }
    }
  }
}
</style>
