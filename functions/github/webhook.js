import { ensureStrReqBody } from "../../src/utils"

export async function onRequestPost(context) {
    const {
        request, // same as existing Worker API
        env, // same as existing Worker API
        params, // if filename includes [id] or [[path]]
        waitUntil, // same as ctx.waitUntil in existing Worker API
        next, // used for middleware or to fetch assets
        data, // arbitrary space for passing data between middlewares
    } = context
    const hook_id = request.headers.get('X-GitHub-Hook-ID')
    const installation_id = request.headers.get('X-GitHub-Hook-Installation-Target-ID')
    const signature = request.headers.get('X-Hub-Signature-256')
    if (!signature) {
        console.error(`missing signature hook_id=${hook_id}`)
        return Response.json({ 'err': 'Forbidden' })
    }
    const jsonStr = await ensureStrReqBody(request)
    if (!verifySignature(env.GITHUB_WEBHOOK_SECRET, signature, jsonStr)) {
        console.error(`missing signature signature=${signature}`)
        return Response.json({ 'err': 'Unauthorized' })
    }
    const jsonData = JSON.parse(jsonStr)
    const info = await env.r2webhooks.put(`github/${installation_id}/${jsonData.action}/${hook_id}.json`, jsonStr)

    return new Response(info)
}

async function verifySignature(secret, header, payload) {
    let encoder = new TextEncoder()
    let parts = header.split("=")
    let sigHex = parts[1]

    let algorithm = { name: "HMAC", hash: { name: 'SHA-256' } }

    let keyBytes = encoder.encode(secret)
    let extractable = false
    let key = await crypto.subtle.importKey(
        "raw",
        keyBytes,
        algorithm,
        extractable,
        ["sign", "verify"],
    )

    let sigBytes = hexToBytes(sigHex)
    let dataBytes = encoder.encode(payload)

    return await crypto.subtle.verify(
        algorithm.name,
        key,
        sigBytes,
        dataBytes,
    )
}

function hexToBytes(hex) {
    let len = hex.length / 2
    let bytes = new Uint8Array(len)

    let index = 0
    for (let i = 0; i < hex.length; i += 2) {
        let c = hex.slice(i, i + 2)
        let b = parseInt(c, 16)
        bytes[index] = b
        index += 1
    }

    return bytes
}
