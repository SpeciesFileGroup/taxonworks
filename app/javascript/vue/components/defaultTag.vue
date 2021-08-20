
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
        <p>{{ created ? 'Remove' : 'Create' }} tag: {{ getDefaultElement().firstChild.firstChild.textContent }}.
          <br>
          {{ showCount ? `Used already on ${countTag} ${countTag > 200 ? 'or more' : '' } objects` : ''}}
        </p>
      </template>

      <v-btn
        circle
        :color="created ? 'destroy' : 'create'"
        @click="created ? deleteTag() : createTag()"
      >
        <v-icon
          color="white"
          name="label"
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
      name="label"
      x-small
    />
  </v-btn>
</template>

<script>

import { Tippy } from 'vue-tippy'
import { Tag } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    Tippy,
    VBtn,
    VIcon
  },

  props: {
    globalId: {
      type: String
    },

    showCount: {
      type: Boolean,
      default: false
    },

    count: {
      type: [Number, String],
      default: undefined
    }
  },

  data () {
    return {
      tagItem: undefined,
      keyId: this.getDefault(),
      countTag: undefined,
      created: false
    }
  },

  watch: {
    count: {
      handler (newVal) {
        this.countTag = newVal
      },
      immediate: true
    }
  },

  mounted () {
    this.alreadyTagged()
    document.addEventListener('pinboard:insert', event => {
      const details = event.detail

      if (details.type === 'ControlledVocabularyTerm') {
        this.keyId = this.getDefault()
        if (this.showCount) {
          this.getCount()
        }
        this.alreadyTagged()
      }
    })
  },

  methods: {
    getDefault () {
      const defaultTag = this.getDefaultElement()
      return defaultTag?.getAttribute('data-pinboard-object-id')
    },

    getDefaultElement () {
      return document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')
    },

    alreadyTagged (element) {
      if (!this.keyId) return

      const params = {
        global_id: this.globalId,
        keyword_id: this.keyId
      }
      Tag.exists(params).then(response => {
        this.created = !!response.body
        this.tagItem = response.body
      })
    },

    getCount () {
      if (!this.keyId) return
      const params = {
        keyword_id: [this.keyId],
        per: 100
      }

      Tag.where(params).then(response => {
        this.countTag = response.body.length
      })
    },

    createTag () {
      const tag = {
        keyword_id: this.keyId,
        annotated_global_entity: this.globalId
      }

      Tag.create({ tag }).then(response => {
        this.tagItem = response.body
        this.created = true
        TW.workbench.alert.create('Tag item was successfully created.', 'notice')
      })
    },

    deleteTag () {
      Tag.destroy(this.tagItem.id).then(() => {
        this.created = false
        TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>
