<template>
  <div class="horizontal-left-content">
    <VAutocomplete
      url="/taxon_names/autocomplete"
      label="label_html"
      display="label"
      min="3"
      placeholder="Search taxon name for the new relationship..."
      :add-params="{ type: 'Protonym', 'nomenclature_group[]': group }"
      param="term"
      @get-item="selectTaxon"
      @get-input="name = $event"
    />
    <button
      type="button"
      class="button normal-input button-default margin-small-left"
      @click="
        () => {
          isModalVisible = true
        }
      "
    >
      New
    </button>
    <VModal
      v-if="isModalVisible"
      @close="
        () => {
          isModalVisible = false
        }
      "
    >
      <template #header>
        <h3>Create new {{ group }} taxon name</h3>
      </template>
      <template #body>
        <div>
          <label>Name</label>
          <input
            type="text"
            v-model="name"
            class="full_width"
          />
          <p>
            Are you sure you want to proceed? Type "{{ CONFIRMATION_WORD }}" to
            proceed.
          </p>
          <input
            type="text"
            class="full_width"
            v-model="confirmInput"
            ref="inputtext"
            :placeholder="`Write ${CONFIRMATION_WORD} to continue`"
            @keypress.enter.prevent="create()"
          />
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="!checkInput"
          @click="create()"
        >
          Create
        </button>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { TaxonName } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete'
import VModal from '@/components/ui/Modal'

const CONFIRMATION_WORD = 'CREATE'

const props = defineProps({
  group: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['select'])

const store = useStore()

const ranksList = ref([])
const confirmInput = ref('')
const name = ref('')
const isModalVisible = ref(false)

const nomenclatureCode = computed(
  () => store.getters[GetterNames.GetNomenclaturalCode]
)
const ranks = computed(
  () => store.getters[GetterNames.GetRankList][nomenclatureCode.value]
)
const childRank = computed(() =>
  ranksList.value.find((rank) =>
    rank.endsWith(props.group === 'genus' ? '::Genus' : '::Species')
  )
)

const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const checkInput = computed(
  () =>
    name.value.length > 1 &&
    CONFIRMATION_WORD === confirmInput.value.toUpperCase()
)

onMounted(() => {
  ranksList.value = [].concat(...flatRankList(ranks.value))
})

function flatRankList(rank) {
  return Array.isArray(rank)
    ? rank.map((item) => item.rank_class)
    : Object.keys(rank).map((key) => flatRankList(rank[key]))
}

function selectTaxon({ id }) {
  TaxonName.find(id).then(({ body }) => {
    emit('select', body)
  })
}

function create() {
  TaxonName.create({
    taxon_name: {
      name: name.value,
      rank_class: childRank.value,
      parent_id: taxon.value.id,
      type: 'Protonym'
    }
  })
    .then((response) => {
      emit('select', response.body)
    })
    .catch(() => {})
}
</script>
