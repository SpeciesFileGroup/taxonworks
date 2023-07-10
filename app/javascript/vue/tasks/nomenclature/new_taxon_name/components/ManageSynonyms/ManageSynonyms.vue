<template>
  <div>
    <block-layout
      anchor="manage-synonymy"
      v-if="isInvalid && validTaxon && childrenList.length"
    >
      <template #header>
        <h3>Manage synonymy</h3>
      </template>
      <template #body>
        <spinner-component
          full-screen
          legend="Saving changes..."
          :logo-size="{ width: '100px', height: '100px' }"
          v-if="saving"
        />
        <spinner-component
          legend="Loading..."
          :logo-size="{ width: '100px', height: '100px' }"
          v-if="isLoading"
        />
        <div>
          <p>
            This name is invalid. The valid name is
            <span v-html="validTaxon.name" />
          </p>
          <div class="flex-separate middle margin-medium-bottom">
            <div>
              <label class="display-block">
                <input type="checkbox" />
                Record previous combination
              </label>
              <label>
                <input type="checkbox" />
                Cite previous combination
              </label>
            </div>
            <ManageSynonymsCitation v-model="citations" />
          </div>

          <table class="full_width margin-small-bottom margin-small-top">
            <thead>
              <tr>
                <th>
                  <input
                    type="checkbox"
                    v-model="selectAll"
                  />
                </th>
                <th>Child</th>
                <th>Valid</th>
                <th>Current parent</th>
                <th>New parent</th>
                <th>Options</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="child in childrenList"
                :key="child.id"
              >
                <td>
                  <input
                    :value="child.id"
                    type="checkbox"
                    v-model="selected"
                  />
                </td>
                <td>
                  {{ child.name }}
                </td>
                <td>
                  {{ child.cached_is_valid ? 'Yes' : 'No' }}
                </td>
                <td v-html="child.parent.name" />
                <td>
                  <autocomplete
                    url="/taxon_names/autocomplete"
                    param="term"
                    min="2"
                    label="label"
                    @get-item="(parent) => addNewParent(child.id, parent.id)"
                    :add-params="{
                      type: 'Protonym',
                      'nomenclature_group[]': 'Genus'
                    }"
                    :placeholder="validTaxon.name"
                  />
                </td>
                <td>
                  <div class="horizontal-left-content">
                    <span
                      class="circle-button btn-edit"
                      @click="loadTaxon(child.id)"
                    />
                    <radial-annotator :global-id="child.global_id" />
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          <button
            class="button normal-input button-submit"
            :disabled="!selected.length"
            @click="confirmSave"
          >
            Save
          </button>
        </div>
      </template>
    </block-layout>
    <modal-component
      v-if="showModal"
      @close="showModal = false"
    >
      <template #header>
        <h3>Move taxon names</h3>
      </template>
      <template #body>
        <p>
          This will change all taxon parents. Are you sure you want to proceed?
          Type "MOVE" to proceed.
        </p>
        <input
          type="text"
          class="full_width"
          v-model="moveInput"
          placeholder="Wirte MOVE to continue"
        />
      </template>
      <template #footer>
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="checkInput"
          @click="saveTaxonNames()"
        >
          Move all
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>
import { GetterNames } from '../../store/getters/getters'
import { TaxonName } from 'routes/endpoints'
import { sortArray } from 'helpers/arrays.js'
import RadialAnnotator from 'components/radials/annotator/annotator'
import BlockLayout from 'components/layout/BlockLayout'
import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import Autocomplete from 'components/ui/Autocomplete'
import ManageSynonymsCitation from './ManageSynonymsCitation.vue'

export default {
  components: {
    ModalComponent,
    RadialAnnotator,
    SpinnerComponent,
    Autocomplete,
    BlockLayout,
    ManageSynonymsCitation
  },
  computed: {
    taxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    isInvalid() {
      return !this.taxon.cached_is_valid
    },
    checkInput() {
      return this.moveInput.toUpperCase() !== 'MOVE'
    },

    selectAll: {
      get() {
        return (
          this.selected.length === this.childrenList.length &&
          this.selected.length > 0
        )
      },
      set(value) {
        this.selected = value ? this.childrenList.map((item) => item.id) : []
      }
    }
  },
  data() {
    return {
      childrenList: [],
      selected: [],
      validTaxon: undefined,
      showModal: false,
      moveInput: '',
      saving: false,
      preSelected: [],
      isLoading: false,
      maxSelect: 10,
      citations: []
    }
  },
  watch: {
    taxon: {
      handler(newVal) {
        if (newVal?.id && !newVal.cached_is_valid) {
          TaxonName.find(this.taxon.cached_valid_taxon_name_id).then((res) => {
            this.validTaxon = res.body
            this.isLoading = true
            TaxonName.where({
              parent_id: [this.taxon.id],
              taxon_name_type: 'Protonym',
              per: 500,
              extend: ['parent']
            }).then((response) => {
              const taxonNames = sortArray(response.body, 'name')

              this.childrenList = taxonNames.filter(
                (item) => item.id !== this.taxon.id
              )
              this.isLoading = false
            })
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    loadTaxon(id) {
      if (window.confirm('Are you sure you want to load this taxon name?')) {
        window.open(`/tasks/nomenclature/new_taxon_name/${id}`, `_self`)
      }
    },

    confirmSave() {
      if (this.selected.length >= this.maxSelect) {
        this.showModal = true
      } else {
        if (window.confirm('Are you sure you want to proceed?')) {
          this.saveTaxonNames()
        }
      }
    },

    saveTaxonNames() {
      const promises = []

      this.saving = true
      this.showModal = false
      this.moveInput = ''

      this.selected.forEach((id, index) => {
        const findPreSelected = this.preSelected.find((children) => {
          return children.childrenId === id
        })

        promises.push(
          TaxonName.update(id, {
            taxon_name: {
              parent_id: findPreSelected
                ? findPreSelected.parentId
                : this.taxon.cached_valid_taxon_name_id
            }
          })
        )
      })

      Promise.all(promises).then(
        () => {
          this.childrenList = this.childrenList.filter(
            (children) => !this.selected.includes(children.id)
          )
          this.selected = []
          this.preSelected = []
          this.saving = false
          TW.workbench.alert.create(
            'Taxon name was successfully moved.',
            'notice'
          )
        },
        (response) => {
          this.saving = false
        }
      )
    },

    addNewParent(childrenId, parentId) {
      this.preSelected.push({
        childrenId,
        parentId
      })
    }
  }
}
</script>
