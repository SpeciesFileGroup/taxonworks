export function makeAssertedEnvironmentPayload({
  object,
  environment,
  citation
}) {
  const payload = {
    asserted_environment_object_type: object.objectType,
    asserted_environment_object_id: object.id,
    uri: environment.uri,
    uri_label: environment.uri_label
  }

  if (citation?.source_id) {
    payload.citations_attributes = [
      {
        source_id: citation.source_id,
        is_original: citation.is_original,
        pages: citation.pages
      }
    ]
  }

  return payload
}
