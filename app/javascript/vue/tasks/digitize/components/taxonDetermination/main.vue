<template>
  <block-layout :warning="!taxonDetermination.id">
    <template #header>
      <h3>Determinations</h3>
    </template>
    <template #body>
      <div id="taxon-determination-digitize">
        <fieldset
          class="separate-bottom">
          <legend>OTU</legend>
          <div class="horizontal-left-content separate-bottom align-start">
            <smart-selector
              class="margin-medium-bottom full_width"
              model="otus"
              ref="smartSelector"
              input-id="determination-otu-autocomplete"
              pin-section="Otus"
              pin-type="Otu"
              :autocomplete="false"
              :otu-picker="true"
              target="TaxonDetermination"
              @selected="setOtu"
            />
            <lock-component
              class="margin-small-left"
              v-model="locked.taxon_determination.otu_id"/>
          </div>
          <div
            v-show="otuSelected"
            class="horizontal-left-content">
            <p v-html="otuSelected"/>
            <span
              class="circle-button button-default btn-undo"
              @click="otuId = undefined; otuSelected = undefined"/>
          </div>
        </fieldset>
        <fieldset>
          <legend>Determiner</legend>
          <div class="horizontal-left-content separate-bottom align-start">
            <smart-selector
              class="full_width"
              ref="determinerSmartSelector"
              model="people"
              target="CollectionObject"
              :params="{ role_type: 'Determiner' }"
              :autocomplete-params="{
                roles: ['Determiner']
              }"
              :autocomplete="false"
              @onTabSelected="view = $event"
              @selected="addRole">
              <template #header>
                <role-picker
                  class="role-picker"
                  :autofocus="false"
                  hidden-list
                  ref="rolepicker"
                  role-type="Determiner"
                  v-model="roles"/>
              </template>
              <role-picker
                class="role-picker"
                :autofocus="false"
                :create-form="false"
                role-type="Determiner"
                v-model="roles"/>
            </smart-selector>
            <lock-component
              class="margin-small-left"
              v-model="locked.taxon_determination.roles_attributes"/>
          </div>
        </fieldset>
        <div class="horizontal-left-content date-fields separate-bottom separate-top">
          <div class="separate-left">
            <label>Day</label>
            <input
              type="number"
              v-model="day">
          </div>
          <div class="separate-right separate-left">
            <label>Month</label>
            <input
              type="number"
              v-model="month">
          </div>
          <div class="separate-right">
            <label>Year</label>
            <input
              type="number"
              v-model="year">
          </div>
          <div>
            <label>&nbsp</label>
            <div class="align-start">
              <button
                type="button"
                class="button normal-input button-default separate-left separate-right"
                @click="setActualDate">
                Now
              </button>
              <lock-component v-model="locked.taxon_determination.dates"/>
            </div>
          </div>
        </div>
        <button
          type="button"
          id="determination-add-button"
          :disabled="!otuId"
          class="button normal-input button-submit separate-top"
          @click="addDetermination">
          {{ taxonDetermination.id ? 'Set' : 'Add' }}
        </button>
        <draggable
          class="table-entrys-list"
          tag="ul"
          :item-key="item => item"
          v-model="list"
          @end="updatePosition">
          <template #item="{ element }">
            <li
              class="list-complete-item flex-separate middle">
              <a
                v-if="element.id"
                v-html="element.object_tag"
                :href="openBrowseOtu(element.otu_id)"/>
              <span
                v-else
                v-html="element.object_tag"/>
              <div class="horizontal-left-content">
                <span
                  v-if="element.id"
                  @click="editTaxonDetermination(element)"
                  class="button circle-button btn-edit"/>
                <radial-annotator
                  v-if="element.global_id"
                  :global-id="element.global_id"/>
                <span
                  class="circle-button btn-delete"
                  :class="{ 'button-default': !element.id }"
                  @click="removeTaxonDetermination(element)"/>
              </div>
            </li>
          </template>
        </draggable>
      </div>
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'
import { Otu, TaxonName } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'

import SmartSelector from 'components/ui/SmartSelector.vue'
import RolePicker from 'components/role_picker.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import CreatePerson from '../../helpers/createPerson.js'
import LockComponent from 'components/ui/VLock/index.vue'
import Draggable from 'vuedraggable'
import RadialAnnotator from 'components/radials/annotator/annotator'

export default {
  components: {
    SmartSelector,
    RolePicker,
    BlockLayout,
    LockComponent,
    Draggable,
    RadialAnnotator
  },

  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },

    taxonDetermination: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDetermination, value)
      }
    },

    otu: {
      get () {
        return this.$store.getters[GetterNames.GetTmpData].otu
      },
      set (value) {
        this.$store.commit(MutationNames.SetTmpDataOtu, value)
      }
    },

    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },

    otuId: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination].otu_id
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationOtuId, value)
      }
    },

    day: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination].day_made
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationDay, value)
      }
    },

    month: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination].month_made
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationMonth, value)
      }
    },

    year: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination].year_made
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationYear, value)
      }
    },

    roles: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDetermination].roles_attributes
      },
      set(value) {
        this.$store.commit(MutationNames.SetTaxonDeterminationRoles, value)
      }
    },

    list: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonDeterminations]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonDeterminations, value)
      }
    },

    lastSave () {
      return this.$store.getters[GetterNames.GetLastSave]
    }
  },

  data () {
    return {
      view: undefined,
      otuSelected: undefined
    }
  },

  watch: {
    collectionObject (newVal) {
      this.$refs.rolepicker.reset()
    },

    otuId (newVal) {
      if (newVal) {
        Otu.find(newVal).then(response => {
          this.otuSelected = response.body.object_tag
          this.otu = response.body
        })
      }
      else {
        this.otu = undefined
        this.otuSelected = undefined
      }
    },

    lastSave (newVal) {
      this.$refs.smartSelector.refresh()
      this.$refs.determinerSmartSelector.refresh()
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const otuId = urlParams.get('otu_id')
    const taxonId = urlParams.get('taxon_name_id')

    if (/^\d+$/.test(otuId)) {
      this.otuId = otuId
    }
    if (/^\d+$/.test(taxonId)) {
      TaxonName.otus(taxonId).then(response => {
        if (response.body.length) {
          if (response.body.length === 1) {
            this.setOtu(response.body[0])
          }
          this.$refs.smartSelector.addToList('quick', response.body[0])
        } else {
          Otu.create({ otu: { taxon_name_id: taxonId } }).then(otu => {
            this.setOtu(otu)
            this.$refs.smartSelector.addToList('quick', otu.body)
          })
        }
      })
    }
  },

  methods: {
    roleExist (id) {
      return !!this.roles.find((role) => !role.hasOwnProperty('_destroy') && role.person_id === id)
    },

    addRole (role) {
      if (!this.roleExist(role.id)) {
        this.roles.push(CreatePerson(role, 'Determiner'))
      }
    },

    saveDetermination () {
      this.$store.dispatch(ActionNames.SaveDetermination)
    },

    addDetermination () {
      if (!this.taxonDetermination.id && this.list.find(determination => determination.otu_id === this.taxonDetermination.otu_id && (determination.year_made === this.year))) { return }

      this.taxonDetermination.object_tag = `${this.otuSelected} ${this.authorsString()} ${this.dateString()}`
      this.$store.commit(MutationNames.AddTaxonDetermination, this.taxonDetermination)
      this.$store.commit(MutationNames.NewTaxonDetermination)
    },

    removeTaxonDetermination (determination) {
      this.$store.dispatch(ActionNames.RemoveTaxonDetermination, determination)
    },

    setActualDate () {
      const today = new Date()
      this.day = today.getDate()
      this.month = today.getMonth() + 1
      this.year = today.getFullYear()
    },

    updatePosition () {
      for (let i = 0; i < this.list.length; i++) {
        this.list[i].position = (i + 1)
      }
    },

    setOtu (otu) {
      this.otuId = otu.id
      this.otuSelected = otu.object_tag
    },

    editTaxonDetermination (item) {
      this.taxonDetermination = {
        id: item.id,
        global_id: item.global_id,
        otu_id: item.otu_id,
        day_made: item.day_made,
        month_made: item.month_made,
        year_made: item.year_made,
        position: item.position,
        roles_attributes: item?.determiner_roles || item.roles_attributes || []
      }
    },

    authorsString () {
      return this.taxonDetermination.roles_attributes.length ? `by ${this.taxonDetermination.roles_attributes.map(item => item?.person?.last_name || item.last_name).join(', ')}` : ''
    },

    dateString () {
      if (this.taxonDetermination.day_made || this.taxonDetermination.month_made || this.taxonDetermination.year_made) {
        return `on ${this.taxonDetermination.day_made ? `${this.taxonDetermination.day_made}-` : ''}${this.taxonDetermination.month_made ? `${this.taxonDetermination.month_made}-` : ''}${this.taxonDetermination.year_made ? `${this.taxonDetermination.year_made}` : ''}`
      }
      return ''
    },

    openBrowseOtu (id) {
      return `${RouteNames.BrowseOtu}?otu_id=${id}`
    }
  }
}
</script>

<style lang="scss">
  #taxon-determination-digitize {
    label {
      display: block;
    }
    li label {
      display: inline;
    }
    .date-fields {
      input {
        max-width: 80px;
      }
    }
    .role-picker {
      .vue-autocomplete-input {
        max-width: 150px;
      }
    }
  }

</style>
