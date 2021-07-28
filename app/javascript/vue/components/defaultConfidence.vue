<template>
  <div v-if="keyId">
    <tippy
      animation="scale"
      placement="bottom"
      size="small"
      inertia
      arrow
    >
      <template #content>
        <p>
          {{ created ? 'Remove' : 'Create' }} confidence: {{ getDefaultElement().firstChild.firstChild.textContent }}.
          <br>
          {{ confidenceCount ? `Used already  on ${confidenceCount} ${confidenceCount > 200 ? 'or more' : '' } objects` : '' }}
        </p>
      </template>

      <v-btn
        circle
        :color="created ? 'destroy' : 'create'"
        @click="created ? deleteConfidence() : createConfidence()"
      >
        <v-icon
          color="white"
          name="confidence"
          x-small
        />
      </v-btn>
    </tippy>
  </div>
  <v-btn
    v-else
    circle
    color="disabled"
  >
    <v-icon
      color="white"
      name="confidence"
      x-small
    />
  </v-btn>
</template>

<script>

import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { Tippy } from 'vue-tippy'
import { Confidence } from 'routes/endpoints'

export default {
  name: 'ButtonConfidence',

  components: {
    Tippy,
    VBtn,
    VIcon
  },

  props: {
    globalId: {
      type: String,
      required: true
    },

    tooltip: {
      type: Boolean,
      default: true
    },

    count: {
      type: [Number, String],
      default: undefined
    }
  },

  data () {
    return {
      confidenceItem: undefined,
      keyId: this.getDefault(),
      created: false,
      confidenceCount: undefined
    }
  },

  watch: {
    count: {
      handler (newVal) {
        this.confidenceCount = newVal
      },
      immediate: true
    }
  },

  mounted () {
    this.alreadyCreated()
    document.addEventListener('pinboard:insert', (event) => {
      const details = event.detail
      if (details.type === 'ControlledVocabularyTerm') {
        this.keyId = this.getDefault()
        this.getCount()
        this.alreadyCreated()
      }
    })
  },

  methods: {
    getDefault () {
      const defaultConfidence = this.getDefaultElement()
      return defaultConfidence ? defaultConfidence.getAttribute('data-pinboard-object-id') : undefined
    },

    getDefaultElement () {
      return document.querySelector('[data-pinboard-section="ConfidenceLevels"] [data-insert="true"]')
    },

    alreadyCreated (element) {
      if (!this.keyId) return

      const params = {
        global_id: this.globalId,
        confidence_level_id: this.keyId
      }

      Confidence.exists(params).then(response => {
        if (response.body) {
          this.created = true
          this.confidenceItem = response.body
        } else {
          this.created = false
        }
      })
    },

    getCount () {
      if (!this.keyId) return

      const params = {
        confidence_level_id: [this.keyId],
        per: 100
      }

      Confidence.where(params).then(response => {
        this.confidenceCount = response.body.length
      })
    },

    createConfidence () {
      const confidence = {
        confidence_level_id: this.keyId,
        annotated_global_entity: this.globalId
      }

      Confidence.create({ confidence }).then(response => {
        this.confidenceItem = response.body
        this.created = true
        TW.workbench.alert.create('Confidence item was successfully created.', 'notice')
      })
    },

    deleteConfidence () {
      Confidence.destroy(this.confidenceItem.id).then(() => {
        this.created = false
        TW.workbench.alert.create('Confidence item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>
