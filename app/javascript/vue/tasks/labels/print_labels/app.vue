<template>
  <div>
    <div class="flex-separate middle">
      <h1>Task - Print labels</h1>
      <ul class="no_bullets context-menu">
        <li
          v-for="(link, index) in links"
          :key="index">
          <a :href="link.url">
            {{ link.label }}
          </a>
        </li>
      </ul>
    </div>
    <navbar-component>
      <div class="horizontal-right-content middle">
        <preview-labels
          :disabled="!(styleSelected && selectedLabels.length)"
          class="margin-small-right"
          :class-selected="styleSelected"
          :rows="layout.rows"
          :columns="layout.columns"
          :divisor="layout.divisor"
          :separator="layout.separator"
          :custom-style="customStyle"
          :labels="selectedLabels"/>
        <label-form
          v-model="label"
          @save="saveLabel"/>
      </div>
    </navbar-component>
    <block-layout class="margin-medium-bottom">
      <template #header>
        <h3>Settings</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <style-selector
            class="full_width"
            @onNewStyle="customStyle = $event"
            v-model="styleSelected"/>
          <layout-component
            class="full_width"
            @onRowsChange="layout.rows = $event"
            @onColumnsChange="layout.columns = $event"
            @onSeparatorChange="layout.separator = $event"
            @onDivisorChange="layout.divisor = $event"/>
        </div>
      </template>
    </block-layout>
    <table-component
      :list="list"
      v-model="labels"
      @onRemove="removeLabel"
      @onRemoveAll="deleteLabels"
      @onEdit="editLabel"
      @onUpdate="updateLabel"/>
  </div>
</template>

<script>

import BlockLayout from 'components/layout/BlockLayout'
import StyleSelector from './components/StyleSelector'
import LayoutComponent from './components/Layout'
import TableComponent from './components/Table/TableComponent'
import PreviewLabels from './components/PreviewLabels'
import NavbarComponent from 'components/layout/NavBar'
import LabelForm from './components/LabelForm'
import { RouteNames } from 'routes/routes'
import { Label } from 'routes/endpoints'

export default {
  components: {
    BlockLayout,
    StyleSelector,
    LayoutComponent,
    TableComponent,
    PreviewLabels,
    NavbarComponent,
    LabelForm
  },

  data () {
    return {
      label: undefined,
      labels: [],
      list: [],
      styleSelected: 'ce_lbl_insect_compressed',
      layout: {
        rows: 151,
        columns: 9,
        separator: '',
        divisor: false
      },
      links: [{
        label: 'New collecting event',
        url: RouteNames.NewCollectingEvent
      },
      {
        label: 'New collection object',
        url: '/collection_objects/new'
      }],
      customStyle: ''
    }
  },

  computed: {
    selectedLabels () {
      return this.list.filter(item => this.labels.includes(item.id))
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const labelId = urlParams.get('label_id')

    Label.all().then(response => {
      this.list = response.body
      if (/^\d+$/.test(labelId)) {
        Label.find(labelId).then(r => {
          const index = this.list.findIndex(item => item.id === Number(labelId))

          if (index > -1) {
            this.list.splice(index, 1)
          }
          this.list.unshift(r.body)
          this.labels.unshift(r.body)
        })
      }
    })
  },

  methods: {
    removeLabel (label) {
      Label.destroy(label.id).then(() => {
        this.list.splice(this.list.findIndex(item => item.id === label.id), 1)
        TW.workbench.alert.create('Label item was successfully destroyed.', 'notice')
      })
    },
    deleteLabels () {
      this.labels.forEach(label => {
        this.removeLabel(label)
      })
      this.labels = []
    },
    createLabel (label) {
      Label.create({ label }).then(response => {
        this.list.unshift(response.body)
        TW.workbench.alert.create('Label item was successfully created.', 'notice')
      })
    },
    updateLabel (label) {
      Label.update(label.id, { label }).then(response => {
        const index = this.list.findIndex(item => item.id === label.id)

        this.list[index] = response.body
        TW.workbench.alert.create('Label item was successfully updated.', 'notice')
      })
    },
    editLabel (label) {
      this.label = label
    },
    saveLabel (label) {
      if (label.id) {
        this.updateLabel(label)
      } else {
        this.createLabel(label)
      }
    }
  }
}
</script>
