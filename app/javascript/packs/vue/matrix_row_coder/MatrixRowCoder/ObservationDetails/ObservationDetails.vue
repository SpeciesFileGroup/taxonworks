<template>
    <div class="observation-details">
        <confidence-levels
            v-bind:confidences="observation.confidences">
        </confidence-levels>

        <notes
            v-bind:notes="observation.notes">
        </notes>

        <depictions
            v-bind:depictions="observation.depictions">
        </depictions>

        <citations
            v-bind:citations="observation.citations">
        </citations>
    </div>
</template>

<style src="./ObservationDetails.styl" lang="stylus"></style>

<script>
    import confidenceLevels from '../ConfidenceLevels/ConfidenceLevels.vue';
    import notes from '../Notes/Notes.vue';
    import depictions from '../Depictions/Depictions.vue';
    import citations from '../Citations/Citations.vue';

    export default {
        name: "observation-details",
        props: ['observation'],
        components: {
            confidenceLevels,
            notes,
            depictions,
            citations
        }
    };
</script>