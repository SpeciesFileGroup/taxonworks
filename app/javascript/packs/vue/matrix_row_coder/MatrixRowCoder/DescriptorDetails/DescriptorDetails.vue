<template>
    <div class="descriptor-details">
        <p>{{ descriptor.description }}</p>
        <notes
                v-bind:notes="descriptor.notes">
        </notes>
        <depictions
                v-bind:depictions="descriptor.depictions">
        </depictions>
    </div>
</template>

<script>
    import notes from '../Notes/Notes.vue';
    import depictions from '../Depictions/Depictions.vue';

    export default {
        name: 'descriptor-details',
        props: ['descriptor'],
        components: {
            notes,
            depictions
        }
    }
</script>