<template>
  <div class="position-absolute">
    <button
      @click="show = true"
      class="button normal-input button-default grid-button">#</button>
    <modal-component
      v-if="show"
      @close="show = false">
      <h3 slot="header">Quick grid</h3>
      <fieldset slot="body">
        <legend>Quick grid</legend>
        <div class="flex-separate middle">
        <div class="horizontal-left-content middle">
          <div class="margin-small-right">
            <label>Rows:</label>
            <input
              class="grid-input"
              v-model="rows"
              type="number"> 
          </div>
          <div class="margin-small-right">
            <label>Columns:</label>
            <input
              class="grid-input"
              v-model="columns"
              type="number"> 
          </div>
          <button
            class="button normal-input button-default"
            @click="createGrid">Set</button>
          <button
            class="button normal-input button-submit margin-small-left"
            @click="saveGrid"
            >Save</button>
        </div>
          <div class="horizontal-left-content margin-medium-left">
            <button
              class="button normal-input button-default margin-small-right"
              @click="setGrid(10, 2)">10x2</button>
            <button 
              class="button normal-input button-default margin-small-right"
              @click="setGrid(10, 3)">10x3</button>
            <button class="button normal-input button-default"
              @click="setGrid(1, 1)">1x1</button>
          </div>
        </div>
      </fieldset>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import ScaleValue from 'helpers/scale'
import { GetUserPreferences, UpdateUserPreferences } from '../../request/resource'

export default {
  components: {
    ModalComponent
  },
  props: {
    height: {
      type: Number,
      required: true
    },
    width: {
      type: Number,
      required: true
    },
    verticalLines: {
      type: Array,
      default: []
    },
    horizontalLines: {
      type: Array,
      default: []
    }
  },
  data () {
    return {
      rows: 1,
      columns: 1,
      show: false,
      preferences: undefined,
      configString: 'tasks::griddigitize::quickgrid'
    }
  },
  mounted () {
    GetUserPreferences().then(response => {
      this.preferences = response.body
      let sizes = this.preferences.layout[this.configString]
      if(sizes) {
        let grid = {
          vlines: sizes.columns.map(column => column * this.width),
          hlines: sizes.rows.map(row => row * this.height)
        }
        this.$emit('onLines', grid)
      }
    })
  },
  methods: {
    createGrid () {
      let wSize = this.width/this.columns
      let hSize = this.height/this.rows
  
      let vlines = this.segments(wSize, this.columns)
      let hlines = this.segments(hSize, this.rows)

      this.$emit('grid', { vlines: vlines, hlines: hlines })
    },
    segments (size, parts) {
      let segments = []

      for(let i = 0; i <= parts; i++) {
        segments.push(size * i)
      }
      return segments
    },
    setGrid(rows, columns) {
      this.columns = columns
      this.rows = rows
      this.createGrid()
    },
    scaleSize(size, lines) {
      let scale = []
      for(let i = 0; i <= lines; i++) {
        scale.push(i / size)
      }
      return scale
    },
    saveGrid() {
      let columns = this.verticalLines.map(line => { return ScaleValue(line, 0, this.width, 0, 1) })
      let rows = this.horizontalLines.map(line => { return ScaleValue(line, 0, this.height, 0, 1) })

      UpdateUserPreferences(this.preferences.id, { [this.configString]: { columns: columns, rows: rows } }).then(response => {
        this.preferences = response.body
        TW.workbench.alert.create('Preferences was successfully updated.', 'notice')
      })
    }
  }
}
</script>

<style lang="scss" scoped>
  /deep/ .modal-container {
    width: 500px
  }
  .grid-button {
    top: 10px;
    width: 22px;
    height: 22px;
    text-align: center;
  }
  .grid-input {
    width: 50px;
  }
</style>