<template>
  <block-layout>
    <template #header>
      <h3>Protocols</h3>
    </template>
    <template #options>
      <div>
        <a href="/protocols/new">Create new</a>
      </div>
    </template>
    <template #body>
      <div class="horizontal-left-content align-start">
        <smart-selector
          class="full_width"
          model="protocols"
          klass="Extract"
          @selected="addProtocol"/>
        <lock-component
          class="margin-small-left"
          v-model="settings.lock.protocols"/>
      </div>
      <display-list
        :list="protocols"
        :label="['protocol', 'object_label']"
        @deleteIndex="removeProtocol"
      />
    </template>
  </block-layout>
</template>

<script>

import LockComponent from 'components/ui/VLock/index.vue'
import SmartSelector from 'components/ui/SmartSelector'
import componentExtend from './mixins/componentExtend'
import DisplayList from 'components/displayList'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ProtocolRelationship } from 'routes/endpoints'
import BlockLayout from 'components/layout/BlockLayout'

export default {
  mixins: [componentExtend],

  components: {
    LockComponent,
    SmartSelector,
    DisplayList,
    BlockLayout
  },

  computed: {
    protocols: {
      get () {
        return this.$store.getters[GetterNames.GetProtocols]
      },
      set (value) {
        this.$store.commit(MutationNames.SetProtocols, value)
      }
    }
  },

  methods: {
    addProtocol ({ id, object_tag }) {
      this.$store.commit(MutationNames.AddProtocol, { protocol_id: id, object_tag })
    },

    removeProtocol (index) {
      if (this.protocols[index].id) {
        ProtocolRelationship.destroy(this.protocols[index].id)
      }
      this.$store.commit(MutationNames.RemoveProtocol, this.protocols[index].id)
    }
  }
}
</script>
