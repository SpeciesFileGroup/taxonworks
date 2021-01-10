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
          :disabled="!(styleSelected && labels.length)"
          class="margin-small-right"
          :class-selected="styleSelected"
          :rows="layout.rows"
          :columns="layout.columns"
          :divisor="layout.divisor"
          :separator="layout.separator"
          :custom-style="customStyle"
          :labels="labels"/>
        <label-form
          v-model="label"
          @save="saveLabel"/>
      </div>
    </navbar-component>
    <block-layout class="margin-medium-bottom">
      <h3 slot="header">Settings</h3>
      <div
        slot="body"
        class="horizontal-left-content align-start">
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

import BlockLayout from 'components/blockLayout'
import StyleSelector from './components/StyleSelector'
import LayoutComponent from './components/Layout'
import TableComponent from './components/Table/TableComponent'
import PreviewLabels from './components/PreviewLabels'
import NavbarComponent from 'components/navBar'
import LabelForm from './components/LabelForm'
import { RouteNames } from 'routes/routes'
import { GetLabels, GetLabel, RemoveLabel, UpdateLabel, CreateLabel } from './request/resources.js'

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
  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const labelId = urlParams.get('label_id')

    GetLabels().then(response => {
      this.list = response.body
      if (/^\d+$/.test(labelId)) {
        GetLabel(labelId).then(r => {
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
      RemoveLabel(label.id).then(() => {
        this.list.splice(this.list.findIndex(item => item.id === label.id), 1)
        TW.workbench.alert.create('Label item was successfully destroyed.', 'notice')
      })
    },
    deleteLabels () {
      this.labels.forEach((label, index) => {
        this.removeLabel(label)
      })
      this.labels = []
    },
    createLabel (label) {
      CreateLabel(label).then(response => {
        this.list.unshift(response.body)
        TW.workbench.alert.create('Label item was successfully created.', 'notice')
      })
    },
    updateLabel (label) {
      UpdateLabel(label).then(response => {
        const index = this.list.findIndex(item => {
          return item.id === label.id
        })
        TW.workbench.alert.create('Label item was successfully updated.', 'notice')
        this.$set(this.list, index, response.body)
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
