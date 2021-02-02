addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

/**
 * Respond to the request
 * @param {Request} request
 */
async function handleRequest(request) {
  return new Response('User-agent: *'+'\n'+'Disallow: /'+'\n', {status: 200})
}