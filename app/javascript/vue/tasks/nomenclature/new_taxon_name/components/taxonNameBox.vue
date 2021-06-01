<template>
  <div id="taxonNameBox">
    <modal
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Confirm delete</h3>
      <div slot="body">Are you sure you want to delete <span v-html="parent.object_tag"/> {{ taxon.name }} ?</div>
      <div slot="footer">
        <button
          @click="deleteTaxon()"
          type="button"
          class="normal-input button button-delete">Delete</button>
      </div>
    </modal>
    <div class="panel basic-information">
      <div class="content header">
        <div
          v-if="taxon.id"
          class="flex-separate middle">
          <a
            v-shortkey="[getMacKey(), 'b']"
            @shortkey="switchBrowse()"
            :href="`/tasks/nomenclature/browse?taxon_name_id=${taxon.id}`"
            class="taxonname">
            <span v-html="taxon.cached_html"/>
            <span v-html="taxon.cached_author_year"/>
          </a>
          <div class="flex-wrap-column">
            <div
              v-shortkey="[getMacKey(), 'o']"
              @shortkey="switchBrowseOtu()"
              class="horizontal-right-content">
              <radial-annotator :global-id="taxon.global_id" />
              <otu-radial
                :object-id="taxon.id"
                :redirect="false"
              />
              <otu-radial
                ref="browseOtu"
                :object-id="taxon.id"
                :taxon-name="taxon.object_tag"/>
              <radial-object :global-id="taxon.global_id" />
            </div>
            <div class="horizontal-right-content">
              <pin-object
                v-if="taxon.id"
                :pin-object="taxon['pinboard_item']"
                :object-id="taxon.id"
                :type="taxon.base_class"/>
              <default-confidence :global-id="taxon.global_id"/>
              <span
                v-if="taxon.id"
                @click="showModal = true"
                class="circle-button btn-delete"/>
            </div>
          </div>
        </div>
        <h3
          class="taxonname"
          v-else>New</h3>
      </div>
    </div>
  </div>
</template>
<script>

import OtuRadial from 'components/otu/otu.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import DefaultConfidence from 'components/defaultConfidence.vue'
import PinObject from 'components/pin.vue'

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import Modal from 'components/ui/Modal.vue'
import getMacKey from 'helpers/getMacKey'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    Modal,
    RadialAnnotator,
    RadialObject,
    OtuRadial,
    PinObject,
    DefaultConfidence
  },
  data: function () {
    return {
      showModal: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },
    showParent () {
      if (this.taxon.rank == 'genus') return false

      let groups = ['SpeciesGroup', 'GenusGroup']
      return (this.taxon.rank_string ? (groups.indexOf(this.taxon.rank_string.split('::')[2]) > -1) : false)
    },
    roles () {
      let roles = this.$store.getters[GetterNames.GetRoles]
      let count = (roles == undefined ? 0 : roles.length)
      let stringRoles = ''

      if (count > 0) {
        roles.forEach(function (element, index) {
          stringRoles = stringRoles + element.person.last_name

          if (index < (count - 2)) {
            stringRoles = stringRoles + ', '
          } else {
            if (index == (count - 2)) { stringRoles = stringRoles + ' & ' }
          }
        })
      }
      return stringRoles
    }
  },
  mounted: function () {
    TW.workbench.keyboard.createLegend((getMacKey() + '+' + 'b'), 'Go to browse nomenclature', 'New taxon name')
    TW.workbench.keyboard.createLegend((getMacKey() + '+' + 'o'), 'Go to browse otus', 'New taxon name')
  },
  methods: {
    deleteTaxon: function () {
      AjaxCall('delete', `/taxon_names/${this.taxon.id}`).then(response => {
        this.reloadPage()
      })
    },
    reloadPage: function () {
      window.location.href = '/tasks/nomenclature/new_taxon_name/'
    },
    showAuthor: function () {
      if (this.roles.length) {
        return this.roles
      } else {
        return (this.taxon.verbatim_author ? (this.taxon.verbatim_author + (this.taxon.year_of_publication ? (', ' + this.taxon.year_of_publication) : '')) : (this.citation ? this.citation.source.author_year : ''))
      }
    },
    switchBrowse: function () {
      window.location.replace(`/tasks/nomenclature/browse?taxon_name_id=${this.taxon.id}`)
    },
    getMacKey: getMacKey,
    loadParent () {
      if (this.taxon.id && this.parent.id) {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon).then((response) => {
          window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${response.parent_id}`, '_self')
        })
      }
    },
    switchBrowseOtu () {
      this.$refs.browseOtu.openApp()
    }
  }
}
</script>
<style lang="scss">
#taxonNameBox {
  .annotator {
    width:30px;
    margin-left: 14px;
  }
  .separate-options {
    margin-left: 4px;
    margin-right: 4px;
  }
  .header {
    padding: 1em;
    border: 1px solid #f5f5f5;
  }
  .taxonname {
    font-size: 14px;
  }
}
</style>