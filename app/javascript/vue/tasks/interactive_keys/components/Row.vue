<template>
  <div>
    <span>
      <a
        v-if="row.errors"
        class="cursor-pointer"
        @click="showModal = true">({{ row.errors }})</a>
      <span v-html="row.object.object_tag"/>
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
  }
}
</script>
