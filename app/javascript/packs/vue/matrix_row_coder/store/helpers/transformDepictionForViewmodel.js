const CharacterStateObjectName = "CharacterState";

export default function transformDepiction(depictionData) {
    const depiction = {
        caption: depictionData.caption,
        normalSrc: depictionData.image.result.url,
        mediumSrc: depictionData.image.result.alternatives.medium.url,
        thumbSrc: depictionData.image.result.alternatives.thumb.url
    };

    if (depictionData.depiction_object_type === CharacterStateObjectName)
        depiction.characterStateId = depictionData.depiction_object_id;

    return depiction;
}