<template>
  <div>
    <template>
      <primer-component
        :title="title"
        @selected="addSequence"/>
      <button @click="addSequence()">Add</button>
    </template>
    <h3>Type</h3>
    <ul class="no_bullets">
      <li
        v-for="item in sequenceRelationshipTypes"
        :key="item.value">
        <label>
          <input
            type="radio"
            :value="item.value"
            v-model="type">
          {{ item.label }}
        </label>
      </li>
    </ul> 
    <template>
      <h3>Expression</h3>
      <div class="panel content">
        <div class="flex-separate">
          <ul class="no_bullets context-menu">
            <li v-for="operator in operators">
              <button
                type="button"
                @click="addOperator(operator.value)">
                {{ operator.label }}
              </button>
            </li>
          </ul>
          <div
            class="delete-box"
            @click="expression = []">
            <draggable
              class="delete-drag-box"
              title="Remove all"
              :group="randomGroup"/>
          </div>
        </div>
      </div> 
    </template>
    <div v-if="expression.length">
      <div class="separate-bottom horizontal-left-content">
        <draggable
          class="horizontal-left-content expression-box full_width"
          v-model="expression"
          :group="randomGroup">
          <div
            class="drag-expression-element"
            v-for="element in expression"
            :key="element.key">
            {{ element.value }}
          </div>
        </draggable>
      </div>
    </div>
    <button
      type="button"
      class="button normal-input button-submit separate-top"
      @click="sendDescriptor">
      Save
    </button>
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
    },
    descriptor: {
      type: Object,
      required: true
    }
  },
  computed: {
    composeExpression() {
      let formatExpression = []
      this.expression.forEach(item => {
        if(item.type == 'Sequence') {
          formatExpression.push(`${item.relationshipType}.${item.value}`)
        }
        else {
          formatExpression.push(item.value)
        }
      })
      return formatExpression
    },
    geneAttributes() {
      let attributes = []
      let index = 0
      this.expression.forEach((item) => {
        if(item.type == 'Sequence') {
          attributes.push({
            id: item['id'],
            sequence_relationship_type: item.relationshipType,
            sequence_id: item.value, 
            position: index
          })
          index++
        }
      })
      
      return attributes
    }
  },
  data () {
    return {
      sequenceRelationshipTypes: [
        {
          label: 'Forward',
          value: 'SequenceRelationship::ForwardPrimer'
        },
        {
          label: 'Reverse',
          value: 'SequenceRelationship::ReversePrimer'
        }
      ],
      operators: [
        {
          label: 'AND',
          value: '&'
        },
        {
          label: 'OR',
          value: '|'
        },
        {
          label: '(',
          value: '('
        },
        {
          label: ')',
          value: ')'
        }
      ],
      type: 'SequenceRelationship::ForwardPrimer',
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
  watch: {
    descriptor: {
      handler(newVal) {
        if(newVal.hasOwnProperty('gene_attribute_logic')) {
          this.expression = []
          newVal.gene_attribute_logic.split(' ').forEach(item => {
            if(item.includes('.')) {
              let sequence = item.split('.')
              this.expression.push({
                key: (Math.random().toString(36).substr(2, 5)),
                id: newVal.gene_attributes.find((seq) => { return seq.sequence_id == sequence[1] }).id,
                type: 'Sequence',
                relationshipType: sequence[0],
                value: sequence[1]
              })
            }
            else {
              let foundedOperator = this.operators.find(operator => {
                return operator.label == item
              })
              if(foundedOperator) {
                this.addOperator(foundedOperator.value)
              }
            }
          })
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    addSequence(sequenceId = Math.random().toString(36).substr(2, 1).toUpperCase(), sequenceType = undefined) {
      let item = {
        key: (Math.random().toString(36).substr(2, 5)),
        type: 'Sequence',
        relationshipType: sequenceType ? sequenceType : this.type,
        value: sequenceId
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
    },
    sendDescriptor() {
      let newDescriptor = this.descriptor
      
      newDescriptor.gene_attribute_logic = this.composeExpression
      newDescriptor.gene_attributes_attributes = this.geneAttributes

      this.$emit('save', newDescriptor)
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

  .expression-box {
    padding: 4px;
    height: 20px;
    border: 1px solid #EAEAEA;
    background-color: #FAFAFA;
  }

  .delete-drag-box {
    height: 20px;
    width: 20px;
  }

  .delete-box {
    border: 2px dashed #5D9ECE;
    height: 20px;
    width: 20px;
    padding: 5px;
    cursor: pointer;
    background-image: url('../../assets/images/trash.svg');
    background-repeat: no-repeat;
    background-position: center;
    background-size: 17px;
    background-color: #FAFAFA;
    border-radius: 0px;
    border-style: dashed;
    transition:
      border-radius 0.5s ease,
      border-style 0.5s ease,
      background-color 0.5s ease,
      background-image 0.5s ease;
  }

  .delete-box:hover {
    transition:
      border-radius 0.5s ease,
      border-style 0.5s ease,
      background-color 0.5s ease,
      background-image 0.5s ease;
    border-radius: 50%;
    border-color: transparent;
    background-image: url('../../assets/images/w_trash.svg');
    border-style: solid;
    background-color: #5D9ECE;
  }
</style>

