<template>
  <block-layout>
    <template #header>
      <h3>Identifier</h3>
    </template>
    <template #body>
      <div class="full_width flex-col gap-small">
        <ul class="no_bullets">
          <li
            v-for="(_, key) in typeList"
            :key="key"
          >
            <label class="capitalize">
              <input
                type="radio"
                v-model="typeListSelected"
                :value="key"
              />
              {{ key }}
            </label>
          </li>
        </ul>
        <template v-if="typeListSelected">
          <SelectType
            v-model="typeSelected"
            :list="typeList[typeListSelected]"
          />
        </template>

        <template v-if="typeSelected">
          <namespace-component
            v-if="isTypeListLocal"
            v-model:lock="isNamespaceLocked"
            v-model="namespace"
          />
          <identifier-component
            class="margin-small-bottom"
            v-model="identifier"
          />
        </template>

        <div class="horizontal-left-content">
          <button
            type="button"
            class="button btn-primary normal-input"
            :disabled="isMissingData"
            @click="
              () => {
                addIdentifier()
                resetIdentifier()
              }
            "
          >
            Add
          </button>
        </div>
      </div>
      <table
        v-if="identifiers.length"
        class="full_width table-stripe margin-medium-top"
      >
        <thead>
          <tr>
            <th>Identifier</th>
            <th class="w-2"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in identifiers">
            <td v-html="item.object_tag" />
            <td>
              <VBtn
                :color="extractId ? 'destroy' : 'primary'"
                circle
                @click="() => removeIdentifier(index)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </block-layout>
</template>

<script>
import { IDENTIFIER_UNKNOWN } from '@/constants'
import { Identifier } from '@/routes/endpoints'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Tippy } from 'vue-tippy'
import {
  IDENTIFIER_LOCAL_RECORD_NUMBER,
  IDENTIFIER_LOCAL_FIELD_NUMBER
} from '@/constants'

import componentExtend from './mixins/componentExtend'
import SelectType from './Identifiers/SelectType'
import NamespaceComponent from './Identifiers/Namespace'
import IdentifierComponent from './Identifiers/Identifier'
import DisplayList from '@/components/displayList'
import BlockLayout from '@/components/layout/BlockLayout'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ActionNames from '../store/actions/actionNames'

const EXCLUDE_IDENTIFIER_TYPES = [
  IDENTIFIER_LOCAL_FIELD_NUMBER,
  IDENTIFIER_LOCAL_RECORD_NUMBER
]

export default {
  mixins: [componentExtend],

  components: {
    DisplayList,
    SelectType,
    NamespaceComponent,
    IdentifierComponent,
    Tippy,
    BlockLayout,
    VBtn,
    VIcon
  },

  data() {
    return {
      namespace: undefined,
      identifier: undefined,
      typeList: undefined,
      typeListSelected: undefined,
      typeSelected: undefined,
      isNamespaceLocked: false
    }
  },

  computed: {
    identifiers: {
      get() {
        return this.$store.getters[GetterNames.GetIdentifiers]
      },
      set(value) {
        this.$store.commit(MutationNames.SetIdentifiers, value)
      }
    },

    extractId() {
      return this.$store.getters[GetterNames.GetExtract].id
    },

    isTypeListLocal() {
      return this.typeListSelected === 'local'
    },

    isMissingData() {
      if (this.typeListSelected === 'local') {
        return !this.namespace || !this.identifier
      } else if (this.typeListSelected === 'global') {
        return !this.typeSelected || !this.identifier
      }

      return this.typeListSelected ? !this.identifier : true
    }
  },

  watch: {
    typeListSelected(newVal) {
      if (newVal === 'unknown') {
        this.typeSelected = IDENTIFIER_UNKNOWN
      }
    }
  },

  created() {
    Identifier.types().then(({ body }) => {
      const list = body
      const keys = Object.keys(body)

      keys.forEach((key) => {
        const itemList = list[key]
        itemList.common = Object.fromEntries(
          itemList.common
            .filter((type) => !EXCLUDE_IDENTIFIER_TYPES.includes(type))
            .map((item) => [
              item,
              Object.entries(itemList.all).find(([key, _]) => key === item)[1]
            ])
        )

        EXCLUDE_IDENTIFIER_TYPES.forEach((type) => {
          delete list[key].all[type]
        })
      })
      this.typeList = list
    })

    this.$store.subscribeAction({
      after: (action) => {
        if (action.type === ActionNames.ResetState) {
          if (!this.isNamespaceLocked) {
            this.namespace = undefined
          }

          this.identifier = undefined
        }
      }
    })
  },

  methods: {
    addIdentifier() {
      const data = {
        namespace_id: this.namespace?.id,
        object_tag: [this.namespace?.name || '', this.identifier]
          .filter((item) => item)
          .join(' '),
        identifier: this.identifier,
        type: this.typeSelected,
        identifier_object_type: 'Extract'
      }

      this.$store.commit(MutationNames.AddIdentifier, data)
    },

    resetIdentifier() {
      if (!this.isNamespaceLocked) {
        this.namespace = undefined
      }
      this.identifier = undefined
    },

    removeIdentifier(index) {
      const identifier = this.identifiers[index]

      if (identifier.id) {
        if (
          window.confirm(
            "You're trying to delete this record. Are you sure want to proceed?"
          )
        ) {
          Identifier.destroy(identifier.id).then(() => {
            this.$store.commit(MutationNames.RemoveIdentifierByIndex, index)
          })
        }
      } else {
        this.$store.commit(MutationNames.RemoveIdentifierByIndex, index)
      }
    }
  }
}
</script>

<style scoped>
.validate-identifier {
  border: 1px solid red;
}
</style>
