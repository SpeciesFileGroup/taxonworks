<template>
  <div>
    <button
      type="button"
      class="button normal-input button-submit"
      :disabled="!taxon.id || isSaving"
      v-hotkey="shortcuts"
      @click="showModal = true">
      Clone
    </button>
    <modal-component
      v-show="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Clone taxon name</h3>
      </template>
      <template #body>
        <p>
          This will clone the current taxon name with the following information.
        </p>
        <ul class="no_bullets">
          <li
            v-for="field in fieldsToCopy"
            :key="field.value">
            <label>
              <input
                v-model="copyValues"
                :value="field.value"
                :disabled="field.lock"
                type="checkbox">
              {{ field.label }}
            </label>
          </li>
        </ul>
        <p>Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.</p>
        <input
          type="text"
          class="full_width"
          v-model="inputValue"
          @keypress.enter.prevent="cloneTaxon()"
          ref="inputtext"
          :placeholder="`Write ${checkWord} to continue`">
      </template>
      <template #footer>
        <button 
          type="button"
          class="button normal-input button-submit"
          :disabled="checkInput"
          @click="cloneTaxon()">
          Clone
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import ModalComponent from 'components/ui/Modal.vue'
import platformKey from 'helpers/getMacKey'

export default {
  components: {
    ModalComponent
  },
  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+l`] = () => { this.showModal = this.taxon.id && !this.isSaving }

      return keys
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    checkInput () {
      return this.inputValue.toUpperCase() !== this.checkWord
    },
    isSaving () {
      return this.$store.getters[GetterNames.GetSaving]
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
          lock: true,
          default: true
        },
        {
          label: 'Parent',
          value: 'parent_id',
          lock: true,
          default: true
        },
        {
          label: 'Rank',
          value: 'rank_class',
          lock: true,
          default: true
        },
        {
          label: 'Author',
          value: 'verbatim_author',
          lock: false,
          default: true
        },
        {
          label: 'Year',
          value: 'verbatim_year',
          lock: false,
          default: true
        },
        {
          label: 'Original source',
          value: 'origin_citation',
          lock: false,
          default: true
        },
        {
          label: 'Persons',
          value: 'taxon_name_author_roles',
          lock: false,
          default: true
        },
        {
          label: 'Original combination relationships',
          value: 'original_combination',
          lock: false,
          default: false
        },
        {
          label: 'Add invalid relationship',
          value: 'invalid_relationship',
          lock: false,
          default: false
        }
      ]
    }
  },

  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.$nextTick(() => {
            this.$refs.inputtext.focus()
          })
        }
      }
    }
  },

  mounted () {
    this.copyValues = this.fieldsToCopy.filter(item => item.default).map(item => item.value)
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
