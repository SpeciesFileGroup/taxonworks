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
          <table class="full_width margin-medium-bottom margin-small-top">
            <thead>
              <tr>
                <th class="w-2">
                  <input
                    type="checkbox"
                    v-model="selectAll"
                  />
                </th>
                <th>Child</th>
                <th class="w-2">Valid</th>
                <th>Current parent</th>
                <th>New parent</th>
                <th class="w-2">Options</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="child in childrenList">
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
                <td v-html="child.parent.object_tag" />
                <td>
                  <autocomplete
                    url="/taxon_names/autocomplete"
                    param="term"
                    min="2"
                    label="label"
                    @getItem="addPreSelected(child.id, $event.id)"
                    :add-params="{
                      type: 'Protonym',
                      'nomenclature_group[]': 'Genus'
                    }"
                    :placeholder="validTaxon.name"
                  />
                </td>
                <td>
                  <div class="horizontal-left-content gap-xsmall">
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
    <VModal
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
    </VModal>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { RouteNames } from '@/routes/routes'
import { TaxonName } from '@/routes/endpoints'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import BlockLayout from '@/components/layout/BlockLayout'
import VModal from '@/components/ui/Modal'
import SpinnerComponent from '@/components/ui/VSpinner'
import Autocomplete from '@/components/ui/Autocomplete'

export default {
  components: {
    VModal,
    RadialAnnotator,
    SpinnerComponent,
    Autocomplete,
    BlockLayout
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
        return this.selected.length === this.childrenList.length
      },
      set(value) {
        this.selected = value
          ? (this.selected = this.childrenList.map((child) => child.id))
          : []
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
      maxSelect: 10
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
              sort: 'alphabetical',
              extend: ['parent']
            })
              .then(({ body }) => {
                this.childrenList = body.filter(
                  (item) => item.id !== this.taxon.id
                )
              })
              .finally(() => {
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
        window.open(`${RouteNames.NewTaxonName}?taxon_name_id=${id}`, `_self`)
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

    addPreSelected(childrenId, parentId) {
      this.preSelected.push({
        childrenId: childrenId,
        parentId: parentId
      })
    }
  }
}
</script>
