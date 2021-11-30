<template>
  <div>
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
    <primer-component
      class="separate-top"
      :title="title"
      @selected="addSequence"/>

    <h3>Expression</h3>
    <div class="panel content">
      <div class="flex-separate">
        <ul class="no_bullets context-menu">
          <li
            v-for="operator in operators"
            :key="operator">
            <button
              type="button"
              @click="addOperator(operator)">
              {{ operator }}
            </button>
          </li>
        </ul>
        <div
          class="delete-box"
          @click="removeAll">
          <draggable
            class="delete-drag-box"
            title="Remove all"
            v-model="trashExpressions"
            :group="randomGroup">
            <template #item="{ element }">
              <div class="d-none"/>
            </template>
          </draggable>
        </div>
      </div>
    </div>

    <div
      v-if="expression.length">
      <div class="separate-bottom horizontal-left-content">
        <draggable
          class="horizontal-left-content expression-box full_width"
          :class="{ 'warning-box': (isParensOpen || !validateExpression) }"
          v-model="expression"
          item-key="key"
          :group="randomGroup">
          <template #item="{ element }">
            <div
              class="drag-expression-element horizontal-left-content feedback"
              :class="element.type == 'Operator' ? 'feedback-secondary' : 'feedback-primary'">
              {{ element.name }}
            </div>
          </template>
        </draggable>
      </div>
      <div
        v-if="isParensOpen || !validateExpression"
        class="warning-message">
        Invalid expression:
        <span
          v-if="isParensOpen">
          Close parentheses.
        </span>
        <span v-if="!validateExpression">
          Logical operators needs sequence on the other side.
        </span>
      </div>
    </div>
    <button
      type="button"
      class="button normal-input button-submit separate-top"
      :disabled="!validateExpression || isParensOpen || !geneAttributes.length || !descriptor.name"
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
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'save'
  ],

  computed: {
    descriptor: {
      get () {
        return this.modelValue
      },
      set () {
        this.$emit('update:modelValue', this.value)
      }
    },

    composeExpression () {
      const formatExpression = this.expression.map(item =>
        item.type === 'Sequence'
          ? `${item.relationshipType}.${item.value}`
          : ` ${item.value} `
      )

      return formatExpression.join('')
    },
    geneAttributes () {
      return this.expression
        .filter(item => item.type === 'Sequence')
        .map((item, index) => ({
          id: item?.id,
          sequence_relationship_type: item.relationshipType,
          sequence_id: item.value,
          position: index
        }))
    },
    isParensOpen () {
      let parenOpen = false
      let parenClose = false
      const parensOpen = []
      const parensClosed = []
      const foundedParens = this.expression.filter(item => item.type === 'Operator' && (item.value === '(' || item.value === ')'))

      for (let i = 0; i < foundedParens.length; i++) {
        if (foundedParens[i].value === ')') {
          parensClosed.push(i)
          if (parenOpen) {
            parenOpen = false
            parenClose = false
          } else if (parensClosed.length !== parensOpen.length) {
            parenClose = true
          }
        }
        else {
          if (foundedParens[i].value === '(') {
            parensOpen.push(i)
            parenOpen = true
          }
        }
      }
      return ((parenOpen || parenClose) || (parensOpen.length != parensClosed.length) || (parensOpen[parensOpen.length - 1] > parensClosed[parensClosed.length - 1]))
    },
    validateExpression () {
      let previousOperator = true
      let currentOperator = false
      let validated = true

      for (let i = 0; i < this.expression.length; i++) {
        if (this.expression[i].type === 'Operator') {
          if (this.expression[i].value !== ')' && this.expression[i].value !== '(') {
            currentOperator = true
            if (previousOperator) {
              validated = false
              break
            }
          } else {
            if (this.expression[i].value === ')' && previousOperator) {
              validated = false
              break
            }
          }
        } else {
          currentOperator = false
        }
        previousOperator = currentOperator
      }

      if (currentOperator && previousOperator) {
        return false
      }

      return validated
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
        },
        {
          label: 'Blast query sequence',
          value: 'SequenceRelationship::BlastQuerySequence'
        },
        {
          label: 'Reference sequence for assembly',
          value: 'SequenceRelationship::ReferenceSequenceForAssembly'
        }
      ],
      operators: ['AND', 'OR', '(', ')'],
      type: 'SequenceRelationship::ForwardPrimer',
      operatorMode: false,
      randomGroup: Math.random().toString(36).substr(2, 1).toUpperCase(),
      expression: [],
      trashExpressions: [],
      showMenu: false,
      styleMenu: {
        top: 40,
        left: 40
      }
    }
  },
  watch: {
    descriptor: {
      handler (newVal) {
        if (newVal?.gene_attribute_logic) {
          this.expression = []

          newVal.gene_attribute_logic.split(' ').forEach(item => {
            if (item.includes('.')) {
              const [sequenceType, sequenceId] = item.split('.')
              const sequenceObject = newVal.gene_attributes.find(seq => seq.sequence_id == sequenceId)

              this.expression.push({
                key: (Math.random().toString(36).substr(2, 5)),
                id: sequenceObject.id,
                type: 'Sequence',
                name: sequenceObject.sequence.name,
                relationshipType: sequenceType,
                value: Number(sequenceId)
              })
            } else {
              const foundedOperator = this.operators.find(operator => operator === item)

              if (foundedOperator) {
                this.addOperator(foundedOperator)
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
    addSequence (sequence, sequenceType = undefined) {
      const item = {
        key: (Math.random().toString(36).substr(2, 5)),
        name: sequence.name,
        type: 'Sequence',
        relationshipType: sequenceType || this.type,
        value: sequence?.sequence_id || sequence.id
      }

      this.expression.push(item)
      this.operatorMode = true
    },

    addOperator (operator) {
      const item = {
        key: (Math.random().toString(36).substr(2, 5)),
        type: 'Operator',
        name: operator,
        value: operator
      }

      this.expression.push(item)
      this.operatorMode = false
    },
    filterDuplicates (sequencesArray) {
      return sequencesArray.map(e => e['sequence_id'])
        .map((e, i, final) => final.indexOf(e) === i && i)
        .filter(e => sequencesArray[e]).map(e => sequencesArray[e])
    },

    removeAll () {
      this.trashExpressions = this.geneAttributes.filter(item => item.id)
      this.expression = []
      if (this.descriptor.id) {
        this.sendDescriptor()
      }
    },

    sendDescriptor () {
      this.descriptor.gene_attribute_logic = this.composeExpression
      this.descriptor.gene_attributes_attributes = this.filterDuplicates(this.geneAttributes)

      this.trashExpressions.forEach(item => {
        if (item?.id) {
          this.descriptor.gene_attributes_attributes.push({
            id: item.id,
            _destroy: true
          })
        }
      })

      this.$emit('save', this.descriptor)
      this.trashExpressions = []
    }
  }
}
</script>
<style lang="scss" scoped>
  .feedback {
    margin-bottom: 0px;
  }
  .drag-expression-element {
    padding: 2px;
    cursor: pointer;
    text-align: center;
    margin: 4px;
  }

  .drag-expression-element:hover {
    border: 1px solid #EAEAEA;
    border-radius: 3px;
  }

  .expression-box {
    padding: 8px;
    box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, 0.2);
    border-top: 1px solid #EAEAEA;
    background-color: #FAFAFA;
  }

  .delete-drag-box {
    height: 20px;
    width: 20px;
  }

  .warning-message {
    color: red
  }

  .warning-box {
    border: 1px solid red;
    background-color: #ffa9a9 !important;
    color: #FFFFFF !important;
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

