<template>
  <div class="position-relative">
    <div class="hexagon-validation">
      <div
        class="cursor-pointer middle"
        @click="loadSoftValidation"
        v-html="badge"/>
      <div class="panel content hexagon-information">
        <ul class="no_bullets">
          <li
            class="horizontal-left-content"
            v-for="(segment, key) in segments">
            <div
              class="hexagon-info-square margin-small-right"
              :style="{ 'background-color': key }"/>
            {{ segment }}
          </li>
        </ul>
      </div>
    </div>
    <modal-component
      v-if="showValidation"
      @close="showValidation = false">
      <h3 slot="header">Soft validation</h3>
      <div slot="body">
        <template v-if="validation.collectionObject.length">
          <h3>Collection object</h3>
          <ul class="no_bullets">
            <li v-for="item in validation.collectionObject">
              <span data-icon="warning" v-html="item.message"/>
            </li>
          </ul>
        </template>
        <template v-if="validation.collectingEvent.length">
          <h3>Collecting event</h3>
          <ul class="no_bullets">
            <li v-for="item in validation.collectingEvent">
              <span data-icon="warning" v-html="item.message"/>
            </li>
          </ul>
        </template>
      </div>
    </modal-component>
  </div>
</template>

<script>


import { GetterNames } from '../../store/getters/getters'
import { SoftValidation } from 'routes/endpoints'
import ModalComponent from 'components/modal'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    ModalComponent,
  },
  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    settings () {
      return this.$store.getters[GetterNames.GetSettings]
    },
    lastSave () {
      return this.$store.getters[GetterNames.GetSettings].lastSave
    },
    taxonDeterminations () {
      return this.$store.getters[GetterNames.GetTaxonDeterminations]
    }
  },
  data () {
    return {
      validation: {
        collectingEvent: [],
        collectionObject: []
      },
      badge: undefined,
      showValidation: false,
      isLoading: false,
      segments: {
        yellow: 'Identifiers',
        orange: 'Taxon determinations',
        red: 'Georeferences',
        purple: 'Collecting events',
        blue: 'Buffered determinations',
        green: 'Buffered collecting event'
      }
    }
  },
  watch: {
    lastSave: {
      handler(newVal) {
        if(newVal && this.collectionObject.id) {
          this.getBadge(this.collectionObject.id)
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods:{
    getBadge (id) {
      AjaxCall('get', `/collection_objects/${id}/metadata_badge`).then(response => {
        this.badge = response.body.svg
      })
    },
    loadSoftValidation () {
      const promises = []
      this.showValidation = true
      this.isLoading = true

      promises.push(SoftValidation.find(this.collectionObject.global_id).then(response => {
        this.validation.collectionObject = response.body.validations.soft_validations
      }))
      if (this.collectingEvent.id) {
        promises.push(SoftValidation.find(this.collectingEvent.global_id).then(response => {
          this.validation.collectingEvent = response.body.validations.soft_validations
        }))
      }

      Promise.all(promises).then(() => {
        this.isLoading = false
      })
    }
  }
}
</script>

<style lang="scss" scoped>
  ::v-deep .modal-container {
    max-width: 500px;
  }

  .hexagon-validation {
    position: relative;
  }
  .hexagon-validation:hover {
    .hexagon-information {
      display: block;
    }
  }
  .hexagon-information {
    display: none;
    position: absolute;
    padding: 1em;
    width: 170px;
  }
  .hexagon-info-square {
    width: 8px;
    height: 8px;
  }
</style>