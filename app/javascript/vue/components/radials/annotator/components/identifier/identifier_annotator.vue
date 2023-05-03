<template>
  <div class="identifier_annotator">
    <IdentifierList
      :list="typeList"
      v-model="listSelected"
    />
    <div v-if="listSelected">
      <IdentifierType
        v-model="typeIdentifier"
        :list="listSelected"
        :types="typeList[listSelected]"
      />

      <IdentifierLocal
        v-if="isLocal"
        :type="typeIdentifier"
        :object-type="objectType"
        @create="saveIdentifier"
      />
      <IdentifierForm
        v-else
        :type="typeIdentifier"
        @create="saveIdentifier"
      />
    </div>
    <table-list
      :list="list"
      :header="['Identifier', 'Type', '']"
      :attributes="['cached', 'type']"
      :annotator="false"
      @edit="data_attribute = $event"
      @delete="removeItem"
    />
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../../components/annotatorExtend.js'
import TableList from 'components/table_list.vue'
import IdentifierList from './identifierList.vue'
import IdentifierType from './IdentifierType.vue'
import IdentifierLocal from './IdentifierLocal.vue'
import IdentifierForm from './IdentifierForm.vue'
import { Identifier } from 'routes/endpoints'

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: {
    TableList,
    IdentifierList,
    IdentifierType,
    IdentifierForm,
    IdentifierLocal
  },

  computed: {
    isLocal () {
      return this.listSelected === 'local'
    }
  },

  data () {
    return {
      typeList: [],
      typeIdentifier: undefined,
      listSelected: undefined
    }
  },

  created () {
    Identifier.types().then(({ body }) => {
      const list = body
      const keys = Object.keys(body)

      keys.forEach(key => {
        const itemList = list[key]
        itemList.common = Object.fromEntries(
          itemList.common.map(
            item => ([item, Object.entries(itemList.all).find(([key]) => key === item)[1]])
          )
        )
      })

      this.typeList = body
    })
  },

  watch: {
    listSelected () {
      this.typeIdentifier = undefined
    }
  },

  methods: {
    saveIdentifier (params) {
      const identifier = {
        ...params,
        type: this.typeIdentifier,
        identifier_object_id: this.metadata.object_id,
        identifier_object_type: this.metadata.object_type
      }

      Identifier.create({ identifier }).then(response => {
        this.list.push(response.body)
        this.listSelected = undefined
      })
    }
  }
}
</script>
