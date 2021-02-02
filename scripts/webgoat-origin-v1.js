addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})
  
/**
 * Respond to the request
 * @param {Request} request
 */
async function handleRequest(request) {
  request = new Request(request)
  let requestURL = new URL(request.url);
  let response = await fetch(requestURL, request)
  response = new Response(response.body, response)
  response.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains')
  response.headers.set('X-XSS-Protection', '1')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'no-referrer-when-downgrade')
  return response
}