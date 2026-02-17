<template>
    <table class="table-striped full_width">
        <thead>
            <tr>
                <th>
                    <input
                        type="checkbox"
                        :checked="allSelected"
                        @change="toggleSelectAll($event.target.checked)"
                    />
                </th>
                <th />
                <th>scientificName</th>
                <th>Match</th>
                <th>TaxonName</th>
                <th />
                <th>Refine</th>
                <th>OTU</th>
                <th>OTU id</th>
                <th />
                <th>Set</th>
            </tr>
        </thead>
        <tbody>
            <tr
                v-for="row in rows"
                :key="row.index"
                :data-row-index="row.index"
                :class="{
                    'row-disabled': isDuplicate(row),
                    'row-no-match': !row.matched && !row.isEmpty,
                    'row-empty': row.isEmpty,
                }"
            >
                <!-- select -->
                <td>
                    <input
                        type="checkbox"
                        :checked="row.selected"
                        :disabled="isDuplicate(row) || row.isEmpty"
                        @change="
                            emit('update-row', {
                                index: row.index,
                                field: 'selected',
                                value: $event.target.checked,
                            })
                        "
                    />
                </td>

                <!-- context -->
                <td>
                    <button
                        v-if="csvData"
                        class="circle-button"
                        :disabled="!row.csvRow"
                        @click="openContext(row)"
                    >
                        <span>i</span>
                    </button>
                </td>

                <!-- scientificName -->
                <td>
                    <span v-if="row.isEmpty" class="empty-label">EMPTY</span>
                    <span v-else>{{ row.scientificName }}</span>
                </td>

                <!-- match -->
                <td>
                    <input
                        v-if="isActionable(row)"
                        type="text"
                        class="normal-input match-input"
                        :value="row.matchString"
                        placeholder="(uses scientificName)"
                        @change="
                            emit('update-row', {
                                index: row.index,
                                field: 'matchString',
                                value: $event.target.value,
                            })
                        "
                    />
                    <span v-else>{{ row.matchString }}</span>
                </td>

                <!-- TaxonName -->
                <td :class="{ 'cell-ambiguous': row.ambiguous }">
                    <a
                        v-if="row.taxonName"
                        :href="browseTaxonNameUrl(row.taxonNameId)"
                        target="_blank"
                        v-html="row.taxonName.cached_html"
                    />
                </td>

                <!-- radials -->
                <td>
                    <div
                        v-if="row.taxonName"
                        class="horizontal-left-content gap-xsmall"
                    >
                        <RadialAnnotator
                            :global-id="taxonNameGlobalId(row.taxonNameId)"
                        />
                        <RadialNavigator
                            :global-id="taxonNameGlobalId(row.taxonNameId)"
                        />
                    </div>
                </td>

                <!-- reselect (Refine) -->
                <td>
                    <Autocomplete
                        v-if="isActionable(row)"
                        url="/taxon_names/autocomplete"
                        param="term"
                        label="label_html"
                        clear-after
                        placeholder="Search taxon name..."
                        @getItem="
                            (item) =>
                                emit('update-row', {
                                    index: row.index,
                                    field: 'taxonName',
                                    value: item,
                                })
                        "
                    />
                </td>

                <!-- OTU -->
                <td>
                    <template v-if="row.otus.length">
                        <div
                            v-for="otu in row.otus"
                            :key="otu.id"
                            class="horizontal-left-content gap-xsmall"
                        >
                            <input
                                type="radio"
                                :name="'otu-select-' + row.index"
                                :value="otu.id"
                                :checked="row.selectedOtuId === otu.id"
                                :disabled="isDuplicate(row)"
                                @change="
                                    emit('update-row', {
                                        index: row.index,
                                        field: 'selectedOtuId',
                                        value: otu.id,
                                    })
                                "
                            />
                            <span>{{
                                otu.object_label || otu.name || `OTU ${otu.id}`
                            }}</span>
                        </div>
                    </template>
                </td>

                <!-- OTU id -->
                <td>{{ row.selectedOtuId || "" }}</td>

                <!-- create OTU -->
                <td>
                    <VBtn
                        v-if="
                            isActionable(row) &&
                            row.taxonNameId &&
                            !row.otus.length
                        "
                        color="create"
                        small
                        @click="emit('create-otu', { index: row.index })"
                    >
                        Create OTU
                    </VBtn>
                </td>

                <!-- set (duplicate link) -->
                <td>
                    <a
                        v-if="isDuplicate(row)"
                        href="#"
                        @click.prevent="
                            emit('scroll-to-row', activeRowIndex(row))
                        "
                    >
                        → row {{ activeRowIndex(row) + 1 }}
                    </a>
                </td>
            </tr>
        </tbody>
    </table>

    <!-- Context modal -->
    <div v-if="contextRow" class="modal-mask" @click.self="contextRow = null">
        <div class="modal-container">
            <div class="flex-row flex-separate middle margin-medium-bottom">
                <h3>Row context</h3>
                <VBtn circle color="primary" @click="contextRow = null">
                    <VIcon x-small name="close" />
                </VBtn>
            </div>
            <table class="table-striped full_width">
                <tbody>
                    <tr v-for="(value, key) in contextRow.csvRow" :key="key">
                        <td>
                            <strong>{{ key }}</strong>
                        </td>
                        <td>{{ value }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { RouteNames } from "@/routes/routes";
import VBtn from "@/components/ui/VBtn/index.vue";
import VIcon from "@/components/ui/VIcon/index.vue";
import Autocomplete from "@/components/ui/Autocomplete.vue";
import RadialAnnotator from "@/components/radials/annotator/annotator.vue";
import RadialNavigator from "@/components/radials/navigation/radial.vue";

const props = defineProps({
    rows: {
        type: Array,
        required: true,
    },

    csvData: {
        type: Object,
        default: null,
    },
});

const emit = defineEmits(["update-row", "create-otu", "scroll-to-row"]);

const contextRow = ref(null);

const selectableRows = computed(() =>
    props.rows.filter((r) => !r.isEmpty && !isDuplicate(r)),
);

const allSelected = computed(
    () =>
        selectableRows.value.length > 0 &&
        selectableRows.value.every((r) => r.selected),
);

function toggleSelectAll(checked) {
    props.rows.forEach((row) => {
        if (!row.isEmpty && !isDuplicate(row)) {
            emit("update-row", {
                index: row.index,
                field: "selected",
                value: checked,
            });
        }
    });
}

function browseTaxonNameUrl(id) {
    return `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`;
}

function taxonNameGlobalId(id) {
    return `/taxon_names/${id}`;
}

function effectiveName(row) {
    return row.matchString || row.scientificName;
}

function firstUniqueIndex(row) {
    const name = effectiveName(row);
    return props.rows.findIndex((r) => effectiveName(r) === name);
}

function isDuplicate(row) {
    if (row.isEmpty) return false;
    return firstUniqueIndex(row) !== row.index;
}

function isActionable(row) {
    return !isDuplicate(row) && !row.isEmpty;
}

function activeRowIndex(row) {
    return firstUniqueIndex(row);
}

function openContext(row) {
    if (row.csvRow) {
        contextRow.value = row;
    }
}
</script>

<style scoped>
.match-input {
    width: 200px;
}

.cell-ambiguous {
    background-color: #fcf8e3;
}

.row-disabled {
    opacity: 0.6;
}

.row-no-match {
    background-color: #fdf2f2 !important;
}

.row-empty {
    background-color: #f5f5f5 !important;
    opacity: 0.5;
}

.empty-label {
    color: #999;
    font-style: italic;
    font-size: 0.85em;
}

.circle-button {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    border: 1px solid #ccc;
    background: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-style: italic;
    font-weight: bold;
    color: #555;
}

.circle-button:disabled {
    opacity: 0.4;
    cursor: default;
}

.modal-mask {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-container {
    background: white;
    border-radius: 4px;
    padding: 24px;
    max-width: 600px;
    max-height: 80vh;
    overflow-y: auto;
    width: 90%;
}
</style>
