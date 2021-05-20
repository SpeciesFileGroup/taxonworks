<template>
  <modal-component
    :containerStyle="{ width: '500px'}"
    v-if="showModal">
    <h3 slot="header">Select OTU</h3>
    <ul
      class="no_bullets"
      slot="body">
      <li
        v-for="otu in otus"
        :key="otu.id">
        <label class="horizontal-left-content middle">
          <input
            type="radio"
            @click="setOtu(otu)">
          <span v-html="otu.object_tag"/>
        </label>
      </li>
    </ul>
  </modal-component>
</template>

<script>
import ModalComponent from 'components/ui/Modal'
export default {
  components: {
    ModalComponent
  },
  props: {
    otus: {
      type: Array,
      required: true
    }
  },
  computed: {
    showModal () {
      return this.otus.length && !this.otuSelected
    }
  },
  data () {
    return {
      otuSelected: undefined
    }
  },
  methods: {
    setOtu (otu) {
      this.$emit('selected', otu)
    }
  }
}
</script>
