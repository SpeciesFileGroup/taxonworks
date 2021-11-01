<template>
  <div
    v-if="isOtu">
    <v-btn
      color="primary"
      medium
      @click="setModalView(true)">
      Clone and copy
    </v-btn>
    <v-modal
      v-if="isVisible"
      @close="setModalView(false)">
      <template #header>
        <h3>Copy and clone</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li>
            <label>
              <input
                type="radio"
                name="clone"
                :value="true"
                v-model="copy">
              Copy from
            </label>
          </li>
          <li>
            <label>
              <input
                type="radio"
                name="clone"
                :value="false"
                v-model="copy">
              Clone to
            </label>
          </li>
        </ul>
        <br>
        <ul class="no_bullets">
          <li
            v-for="(type, key) in objectType"
            :key="key">
            <label>
              <input
                type="radio"
                name="clone-type"
                :value="key"
                v-model="typeSelected">
              {{ type.label }}
            </label>
          </li>
        </ul>
        <div>
          <autocomplete
            class="separate-top separate-bottom"
            :url="objectType[typeSelected].url"
            min="2"
            param="term"
            label="label_html"
            :placeholder="`Search a ${objectType[typeSelected].label.toLowerCase()}`"
            :clear-after="true"
            display="label"
            @getItem="objectSelected = $event"/>
          <div
            v-if="objectSelected"
            class="horizontal-left-content margin-medium-bottom">
            <span v-html="objectSelected.label_html"/>
            <span
              class="button circle-button btn-undo button-default margin-small-left"
              @click="objectSelected = undefined"/>
          </div>
          <button
            type="button"
            :disabled="!objectSelected"
            @click="cloneScorings"
            class="button normal-input button-submit"
            v-html="buttonLabel"/>
        </div>
      </template>
    </v-modal>
  </div>
</template>

<script>

import VModal from 'components/ui/Modal.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { GetterNames } from '../../store/getters/getters'

export default {
  components: {
    Autocomplete,
    VModal,
    VBtn
  },

  computed: {
    isOtu() {
      return this.$store.getters[GetterNames.GetMatrixRow] &&
      (this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class == 'Otu' || this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class == 'CollectionObject')
    },
    rowGlobalId() {
      return this.$store.getters[GetterNames.GetMatrixRow].row_object.global_id
    },
    rowClass() {
      return this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class
    },
    buttonLabel() {
      return this.copy ? 'Copy observation' : 'Clone observations'
    }
  },

  data () {
    return {
      isVisible: false,
      copy: true,
      typeSelected: 'Otu',
      objectSelected: undefined,
      objectType: {
        Otu: { label: 'OTU', url: '/otus/autocomplete' },
        CollectionObject: { label: 'Collection Object', url: '/collection_objects/autocomplete' }
      }
    }
  },

  methods: {
    cloneScorings() {
      if(window.confirm('Are you sure you want to proceed?')) {
        this.$emit(this.copy ? 'onCopy' : 'onClone', {
          old_global_id: !this.copy ? this.rowGlobalId : this.objectSelected.gid,
          new_global_id: !this.copy ? this.objectSelected.gid : this.rowGlobalId
        })
        this.objectSelected = undefined
      }
    },
    setModalView(value) {
      this.isVisible = value
    }
  }
}
</script>