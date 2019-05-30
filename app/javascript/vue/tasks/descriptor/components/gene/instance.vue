<template>
  <div>
    <h3>{{ title }}</h3>
    <template v-if="!operatorMode">
      <primer-component
        :title="title"
        @selected="addSequence"/>
      <button @click="addSequence()">Add</button>
    </template>
    <template v-else>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              @click="addOperator('&')">
            AND
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              @click="addOperator('|')">
            OR
          </label>
        </li>
      </ul> 
      <button type="button">Done</button>
    </template>
    <div>
      <p>Expression</p>
      <draggable
        class="separate-bottom horizontal-left-content"
        v-model="expression"
        :group="randomGroup">
        <div
          class="drag-expression-element"
          v-for="element in expression"
          :key="element.key"
          @contextmenu.prevent="openMenu($event, element)">{{ element.value }}
        </div>
      </draggable>
      <draggable
        class="delete-box separate-top"
        v-model="expression"
        :group="randomGroup">
      </draggable>
    </div>
  </div>
</template>

<script>

import PrimerComponent from './primer'
import Draggable from 'vuedraggable'

export default {
  components: {
    PrimerComponent,
    Draggable
  },
  props: {
    title: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      operatorMode: false,
      randomGroup: Math.random().toString(36).substr(2, 1).toUpperCase(),
      expression: [],
      showMenu: false,
      styleMenu: {
        top: 40,
        left: 40
      }
    }
  },
  methods: {
    addSequence(sequenceId = Math.random().toString(36).substr(2, 1).toUpperCase()) {
      let item = {
        key: (Math.random().toString(36).substr(2, 5)),
        type: 'Sequence',
        value : sequenceId
      }

      this.expression.push(item)
      this.operatorMode = true
    },
    addOperator(operator) {
      let item = {
        key: (Math.random().toString(36).substr(2, 5)),
        type: 'Operator',
        value: operator
      }
      this.expression.push(item)
      this.operatorMode = false
    }
  }
}
</script>
<style lang="scss" scoped>
  .drag-expression-element {
    padding: 2px;
    width: 10px;
    cursor: pointer;
    text-align: center;
    border: 1px solid transparent;
  }

  .drag-expression-element:hover {
    border: 1px solid #EAEAEA;
    border-radius: 3px;
  }

  .delete-box {
    border: 2px dashed #EAEAEA;
    height: 20px;
    width: 20px;
    padding: 5px;
    background-image: url('../../assets/images/trash.svg');
    background-repeat: no-repeat;
    background-position: center;
    background-size: 20px;
    background-color: #FAFAFA;
  }
</style>

