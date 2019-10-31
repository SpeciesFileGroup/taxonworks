<template>
  <div>
    <button
      type="button"
      class="button normal-input button-submit"
      :disabled="!taxon.id"
      v-shortkey="[getMacKey, 'l']"
      @shortkey="showModal = taxon.id ? true : false"
      @click="showModal = true">
      Clone
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Clone taxon name</h3>
      <div slot="body">
        <p>
          This will clone the current taxon name with the following information.
        </p>
        <ul class="no_bullets">
          <li v-for="field in fieldsToCopy">
            <label>
              <input
                v-model="copyValues"
                :value="field.value"
                :disabled="field.lock"
                type="checkbox"> {{ field.label }} 
            </label>
          </li>
        </ul>
        <p>Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.</p>
        <input
          type="text"
          class="full_width"
          autofocus
          v-model="inputValue"
          @keypress.enter.prevent="cloneTaxon()"
          :placeholder="`Write ${checkWord} to continue`">
      </div>
      <div slot="footer">
        <button 
          type="button"
          class="button normal-input button-submit"
          :disabled="checkInput"
          @click="cloneTaxon()">
          Clone
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import ModalComponent from 'components/modal.vue'

export default {
  components: {
    ModalComponent
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    checkInput () {
      return this.inputValue.toUpperCase() !== this.checkWord
    },
    getMacKey () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    }
  },
  data () {
    return {
      showModal: false,
      inputValue: '',
      checkWord: 'CLONE',
      copyValues: [],
      fieldsToCopy: [
        {
          label: 'Name',
          value: 'name',
          lock: true
        },
        {
          label: 'Parent',
          value: 'parent_id',
          lock: true
        },
        {
          label: 'Rank',
          value: 'rank_class',
          lock: true
        },
        {
          label: 'Author',
          value: 'verbatim_author',
          lock: false
        },
        {
          label: 'Year',
          value: 'verbatim_year',
          lock: false
        },
        {
          label: 'Original source',
          value: 'origin_citation',
          lock: false
        },
        {
          label: 'Persons',
          value: 'taxon_name_author_roles',
          lock: false
        },
        {
          label: 'Original combination relationships',
          value: 'original_combination',
          lock: false
        }
      ]
    }
  },
  mounted () {
    this.copyValues = this.fieldsToCopy.map(item => { return item.value })
  },
  methods: {
    cloneTaxon () {
      if (!this.checkInput) {
        this.$store.dispatch(ActionNames.CloneTaxon, this.copyValues)
      }
    }
  }
}
</script>
