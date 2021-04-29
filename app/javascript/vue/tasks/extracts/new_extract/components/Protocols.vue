<template>
  <div>
    <h2>Protocols</h2>
    <div class="horizontal-left-content align-start">
      <smart-selector
        class="full_width"
        model="protocols"
        klass="extract"
        @selected="addProtocol"/>
      <lock-component
        class="margin-small-left"
        v-model="settings.lock.protocol"/>
    </div>
    <display-list
      :list="protocols"
      @deleteIndex="removeProtocol"
      label="object_tag"/>
  </div>
</template>

<script>

import LockComponent from 'components/lock'
import SmartSelector from 'components/smartSelector'
import componentExtend from './mixins/componentExtend'
import DisplayList from 'components/displayList'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { DestroyProtocol } from '../request/resources'

export default {
  mixins: [componentExtend],

  components: {
    LockComponent,
    SmartSelector,
    DisplayList
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
      this.protocols.push({ protocol_id: id, object_tag })
    },

    removeProtocol (index) {
      if (this.protocols[index].id) {
        DestroyProtocol(this.protocols[index].id).then(() => {
          this.protocols.splice(index, 1)
        })
      } else {
        this.protocols.splice(index, 1)
      }
    }
  }
}
</script>
