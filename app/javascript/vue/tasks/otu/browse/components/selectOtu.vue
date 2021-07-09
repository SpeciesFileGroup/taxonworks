<template>
  <modal-component
    :containerStyle="{ width: '500px'}"
    v-if="showModal">
    <template #header>
      <h3>Select OTU</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
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
    </template>
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

  emits: ['selected'],

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
