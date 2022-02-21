<template>
  <div
    class="figures-container"
    :class="{ 'card-handle' : !edit }">
    <div class="figures-header">
      <img :src="depiction.image.image_file_url">

      <v-btn
        class="figures-delete"
        circle
        medium
        color="destroy"
        @click="deleteDepiction()"
      >
        <v-icon
          x-small
          color="white"
          name="trash"
        />
      </v-btn>

      <v-btn
        class="figures-link"
        circle
        medium
        color="primary"
        @click="linkDepiction()"
      >
        <v-icon
          small
          color="white"
          name="link"
        />
      </v-btn>

      <v-btn
        class="figures-edit"
        circle
        medium
        :color="edit
          ? 'update'
          : 'primary'"
        @click="editChange()"
      >
        <v-icon
          x-small
          color="white"
          name="pencil"
        />
      </v-btn>

      <input
        class="figures-label horizontal-center-content middle"
        v-if="edit"
        type="text"
        v-model="depiction.figure_label">
      <div
        class="figures-label horizontal-center-content middle"
        v-else
      >
        {{ depiction.figure_label }}
      </div>
    </div>
    <div class="figures-body">
      <textarea
        v-if="edit"
        v-model="depiction.caption"
      />
      <span v-else>{{ depiction.caption }}</span>
    </div>
  </div>
</template>
<script>

import { MutationNames } from '../store/mutations/mutations'
import { Depiction } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    VBtn,
    VIcon
  },

  name: 'FigureItem',

  props: {
    figure: {
      type: Object,
      required: true
    }
  },

  emits: ['link'],

  data () {
    return {
      depiction: undefined,
      edit: false
    }
  },

  watch: {
    figure (newVal) {
      this.depiction = newVal
    }
  },

  created () {
    this.depiction = this.figure
  },

  methods: {
    deleteDepiction () {
      Depiction.destroy(this.depiction.id).then(() => {
        this.$store.commit(MutationNames.RemoveDepiction, this.depiction)
      })
    },

    editChange () {
      if (this.edit) {
        this.update()
      }
      this.edit = !this.edit
    },

    update () {
      const depiction = {
        caption: this.depiction.caption,
        figure_label: this.depiction.figure_label
      }

      Depiction.update(this.depiction.id, { depiction }).then(() => {
        TW.workbench.alert.create('Depiction was successfully updated.', 'notice')
      })
    },

    linkDepiction () {
      this.$emit('link', this.depiction)
    }
  }
}
</script>
