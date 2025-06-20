<template>
  <div>
    <h1>Match collection objects</h1>
    <spinner-component
      v-if="isLoading"
      :full-screen="true"
    />
    <div class="horizontal-left-content align-start">
      <div class="full_width margin-small-right">
        <input-component @lines="lines = $event" />
        <div class="flex-separate margin-medium-bottom">
          <button
            class="button normal-input button-default"
            type="button"
            :disabled="!lines.length"
            @click="processList"
          >
            Match
          </button>
          <ul class="no_bullets context-menu">
            <li
              v-for="option in searchParams"
              :key="option.value"
            >
              <label>
                <input
                  v-model="paramSelected"
                  :value="option.value"
                  type="radio"
                />
                {{ option.label }}
              </label>
            </li>
          </ul>
        </div>
        <assign-component :ids="ids" />
      </div>
      <div class="full_width margin-small-left">
        <line-component
          @selected="ids = $event"
          class="margin-small-bottom"
          :match-list="matches"
        />
      </div>
    </div>
  </div>
</template>

<script>
import InputComponent from './components/InputComponent'
import LineComponent from './components/LineComponent'
import AssignComponent from './components/AssignComponent'
import SpinnerComponent from '@/components/ui/VSpinner'
import { CollectionObject } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse'

export default {
  name: 'CollectionObjectMatch',

  components: {
    InputComponent,
    LineComponent,
    AssignComponent,
    SpinnerComponent
  },

  data() {
    return {
      lines: [],
      ids: [],
      maxPerCall: 1,
      exact: false,
      isLoading: false,
      matches: {},
      searchParams: [
        {
          label: 'By ID',
          value: 'GetMatchesById'
        },
        {
          label: 'Identifier exact',
          value: 'GetMatchesByIdentifier'
        }
      ],
      paramSelected: 'GetMatchesByIdentifier'
    }
  },

  created() {
    const urlParams = URLParamsToJSON(location.href)
    const coIds = urlParams.collection_object_id || []
    const identifierIds = urlParams.identifier_id || []

    if (Object.keys(urlParams).length) {
      if (identifierIds.length || coIds.length) {
        this.GetMatchesById(coIds)
        this.GetMatchesByIdentifier(identifierIds)
      } else {
        this.GetMatchByParams(urlParams)
      }
    }
  },

  methods: {
    GetMatchesById(arrayIds = this.lines.filter((line) => Number(line))) {
      const ids = arrayIds.splice(0, this.maxPerCall)
      const promises = ids.map((id) =>
        CollectionObject.find(id).then(
          (response) => {
            this.matches[id] = [response.body]
          },
          () => {
            this.matches[id] = []
          }
        )
      )

      this.isLoading = true

      Promise.allSettled(promises).then(() => {
        if (arrayIds.length) {
          this.GetMatchesById(arrayIds)
        } else {
          this.isLoading = false
        }
      })
    },

    GetMatchesByIdentifier(
      arrayIdentifiers = this.lines.filter((line) => line)
    ) {
      const identifiers = arrayIdentifiers.splice(0, this.maxPerCall)
      const promises = identifiers.map((identifier) =>
        CollectionObject.where({
          identifier_exact: true,
          identifier
        }).then(
          (response) => {
            this.matches[identifier] = response.body
          },
          () => {
            this.matches[identifier] = []
          }
        )
      )

      this.isLoading = true

      Promise.allSettled(promises).then(() => {
        if (arrayIdentifiers.length) {
          this.GetMatchesByIdentifier(arrayIdentifiers)
        } else {
          this.isLoading = false
        }
      })
    },

    GetMatchByParams(params) {
      this.isLoading = true

      CollectionObject.where(params).then(({ body }) => {
        this.matches = Object.fromEntries(body.map((co) => [co.id, [co]]))
        this.isLoading = false
      })
    },

    processList() {
      this.matches = {}
      this.isLoading = true
      this[this.paramSelected]()
    }
  }
}
</script>
