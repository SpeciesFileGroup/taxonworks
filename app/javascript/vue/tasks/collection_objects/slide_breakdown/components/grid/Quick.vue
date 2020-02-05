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
    }
  },
  data () {
    return {
      vlines: [],
      hlines: [],
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
        this.setGrid(sizes.rows, sizes.columns)
      }
    })
  },
  methods: {
    createGrid () {
      let wSize = this.width/this.columns
      let hSize = this.height/this.rows
  
      this.vlines = this.segments(wSize, this.columns)
      this.hlines = this.segments(hSize, this.rows)

      this.$emit('grid', { vlines: this.vlines, hlines: this.hlines })
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
    saveGrid() {
      UpdateUserPreferences(this.preferences.id, { [this.configString]: { columns: this.columns, rows: this.rows } })
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