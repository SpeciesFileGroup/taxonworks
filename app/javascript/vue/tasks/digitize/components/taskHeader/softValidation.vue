<template>
  <div class="position-relative">
    <div class="hexagon-validation">
      <div
        class="cursor-pointer middle"
        @click="showValidation = true"
        v-html="badge"
      />
      <div class="panel content hexagon-information">
        <ul class="no_bullets">
          <li
            class="horizontal-left-content"
            v-for="(segment, key) in segments"
            :key="key"
          >
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
      <template #header>
        <h3>Soft validation</h3>
      </template>
      <template #body>
        <div
          v-for="(typeValidation, key) in softValidations"
          :key="key"
        >
          <h3>{{ typeValidation.title }}</h3>
          <ul class="no_bullets">
            <template
              v-for="(list, i) in typeValidation.list"
              :key="i">
              <li
                v-for="(item, index) in list.soft_validations"
                :key="index">
                <span
                  data-icon="warning"
                  v-html="item.message"/>
              </li>
            </template>
          </ul>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { CollectionObject } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters'
import ModalComponent from 'components/ui/Modal'

export default {
  components: { ModalComponent },

  computed: {
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },

    lastSave () {
      return this.$store.getters[GetterNames.GetSettings].lastSave
    },

    softValidations () {
      return this.$store.getters[GetterNames.GetSoftValidations]
    }
  },

  data () {
    return {
      badge: undefined,
      showValidation: false,
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
      handler (newVal) {
        if (newVal && this.collectionObject.id) {
          this.getBadge(this.collectionObject.id)
        }
      },
      deep: true
    }
  },

  created () {
    this.getBadge(this.collectionObject.id)
  },

  methods: {
    getBadge (id) {
      CollectionObject.metadataBadge(id).then(response => {
        this.badge = response.body.svg
      })
    }
  }
}
</script>

<style lang="scss" scoped>
  :deep(.modal-container) {
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
