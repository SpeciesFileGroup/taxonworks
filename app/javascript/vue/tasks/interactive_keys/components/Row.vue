<template>
  <div>
    <span>
      <a
        v-if="row.errors"
        class="cursor-pointer"
        @click="showModal = true">({{ row.errors }})</a>
      <a :href="getLink(row.object)" v-html="displayLabel(row.object)"/>
    </span>
    <modal-component
      @close="showModal = false"
      :containerStyle="{ width: '500px' }"
      v-if="showModal">
      <h3 slot="header">Error</h3>
      <div slot="body">
        <ul>
          <li
            class="margin-small-bottom"
            v-for="(error, index) in row.error_descriptors"
            :key="index">
            {{ error }}
          </li>
        </ul>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import RanksList from '../const/ranks'
import { GetterNames } from '../store/getters/getters'

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
  data () {
    return {
      showModal: false
    }
  },
  computed: {
    filters () {
      return this.$store.getters[GetterNames.GetParamsFilter]
    }
  },
  methods: {
    displayLabel (obj) {
      return this.filters.identified_to_rank ? obj[RanksList[this.filters.identified_to_rank].label] : obj.object_tag
    },
    getLink (obj) {
      return this.filters.identified_to_rank ? RanksList[this.filters.identified_to_rank].link(obj.id) : undefined
    }
  }
}
</script>
