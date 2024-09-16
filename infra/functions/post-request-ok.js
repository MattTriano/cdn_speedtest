function handler (event) {
  const request = event.request;

  if (request.method == 'POST') {
    return {
        statusCode: 204,
        statusDescription: 'No Content'
    };
  }

  return request;
}
